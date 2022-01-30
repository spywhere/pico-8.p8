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
   from={l=pos.l,c=pos.c},
   to={l=pos.l,c=last_char},
   line=true
  }
 end
end

function to_line(offset, absolute)
 return function (opts)
  local count = max(1, opts.count) * ((offset == nil or absolute) and 0 or offset)
  local last_line = max(1, min(#lines, pos.l + count))

  if absolute then
   last_line = offset == 1 and 1 or #lines
  end

  local last_char = min(pos.c, #lines[last_line])

  if offset == nil then
   last_char = max(1, #lines[last_line])
  end

  return {
   from={l=pos.l,c=pos.c},
   to={l=last_line,c=last_char},
   line=true
  }
 end
end
