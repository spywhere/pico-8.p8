function motion_cmd(fn, operator)
 return function (count)
  if sub(mod, 1, 1) == 'v' then
   local range = {
    from={ l=anchor_pos.l, c=anchor_pos.c },
    to={ l=pos.l, c=pos.c },
    line=mod=='vl',
    block=mod=='vb'
   }
   fn(range)
   mode('n')(0)
   return
  end

  local function build_motion_map(opts, level, motions)
   return setmetatable({}, {
    __index = function (t, k)
     -- handle count inside motion command (e.g. d5w)
     local key = k

     if key == '' then
      return
     end

     if level == 1 and key == operator then
      key = '_'
      motions=motions.g
     elseif level == 1 and key == 'a' or key == 'i' then
      opts.modifier = key
      return build_motion_map(opts, level + 1, motions)
     end

     local new_motion = motions[key]
     if type(new_motion) == 'function' then
      local range=new_motion(opts, key)
      fn(range)
     elseif type(new_motion) == 'table' then
      return build_motion_map(opts, level + 1, new_motion)
     elseif opts.modifier ~= '' and motions[''] then
      local range=motions[''](opts, key)
      fn(range)
     end
    end
   })
  end

  return {
   m=build_motion_map({ modifier='', count=count }, 1, motion)
  }
 end
end

function to_char(offset, absolute)
 return function (opts)
  local count = max(1, opts.count) * ((offset == nil or absolute) and 0 or offset)
  local max_char = max_pos('x')
  local last_char = max(1, min(max_char, pos.c + count))

  if absolute then
   last_char = offset == 1 and 1 or max_char
  end

  return {
   to={l=pos.l,c=last_char},
   line=true
  }
 end
end

function to_line(offset, absolute)
 return function (opts)
  local count = max(1, opts.count) * ((offset == nil or absolute) and 0 or offset)
  local last_line = max(1, min(lines(0), pos.l + count))

  if absolute then
   last_line = offset == 1 and 1 or lines(0)
  end

  local last_char = min(pos.c, #line_at(0, last_line))

  if offset == nil then
   last_char = max(1, #line_at(0, last_line))
  end

  return {
   to={l=last_line,c=last_char},
   line=true
  }
 end
end

function charset(list)
 local function build_charset(from, to)
  local set=''
  for idx=from, to do
   set=set..chr(idx)
  end
  return set
 end

 local set=''
 for item in all(list) do
  if type(item) == 'string' then
   set=set..item
  elseif type(item) == 'table' then
   set=set..build_charset(unpack(item))
  end
 end
 return set
end

function match(chars, char, invert)
 if #char ~= 1 then
  return invert or false
 end
 if #chars < 2 then
  local result = chars == char
  return invert and not result or result
 end

 for idx=1,#chars do
  if char == sub(chars, idx, idx) then
   return not invert and true
  end
 end

 return invert or false
end

function forward_to(chars_fn, invert)
 return function (opts)
  local chars = chars_fn()
  local count = max(1, opts.count)
  local lpos = pos.l
  local cpos = pos.c
  local last_line = lines(0)

  local function forward_to_line(pos, line)
   local line_length = max(1, #line)
   local target=nil
   local isword=match(chars, sub(line, pos, pos), invert)

   for idx=pos+1,line_length do
    local ch=sub(line, idx, idx)
    local isw=match(chars, ch, invert)

    if isw ~= isword then
    elseif not to_end and isw ~= isword then
     if isword and match(const.blank_chars, ch) then
      isword = false
     else
      target = idx
      break
     end
    end
   end

   return target and target <= #line and target or nil
  end

  for c=1,count do
   for idx=1,2 do
    local line=line_at(0, lpos)
    local target_pos = forward_to_line(cpos, line)

    if target_pos then
     cpos = target_pos
     break
    elseif lpos == last_line or lpos == pos.l + 1 then
     break
    else
     cpos = 1
     lpos += 1
    end
   end
  end

  return {
   to={l=lpos,c=cpos}
  }
 end
end

function backward_to(chars)
end
