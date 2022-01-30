function motion_cmd(fn, operator)
 return function (count)
  local function build_motion_map(opts, level, motions)
   return setmetatable({}, {
    __index = function (t, k)
     -- handle count inside motion command (e.g. d5w)
     local key = k

     if level == 1 and key == operator then
      key = '_'
      motions=motions.g
     elseif level == 1 and key == 'a' or key == 'i' then
      opts.modifier = key
      return build_motion_map(opts, level + 1, motions)
     end

     local new_motion = motions[key]
     if type(new_motion) == 'function' then
      local range=motions[key](opts, key)
      fn(range)
     elseif type(new_motion) == 'table' then
      return build_motion_map(opts, level + 1, new_motion)
     elseif opts.modifier ~= '' and motions[''] then
      motions[''](opts, key)
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
