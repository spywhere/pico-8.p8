function set(option)
 local val=true
 local view=false

 if #option < 1 then
  error('e518: unknown option')
  return
 end

 local components=split(option[1], '=')
 local name=components[1]

 if sub(name, #name, #name) == '?' then
  name=sub(name, 1, #name-1)
  view=true
 end
 if sub(name, 1, 2) == 'no' then
  name=sub(name, 3)
  val=false
 end

 local value=components[2]
 local original_name=name

 if opts[name] == nil then
  name = opts_alias[name]
 end

 if opts[name] == nil then
  error('e518: unknown option')
  return
 end

 local value_type=type(opts[name])

 if value_type == 'number' then
  if not val or value and tonum(value) then
   val=val and tonum(value) or 0
  else
   view=true
  end
 end

 if view then
  if value_type == 'number' then
   info('  '..original_name..'='..tostr(opts[name]))
  else
   info((opts[name] and '  ' or 'no')..original_name)
  end
   return
 end
 opts[name]=val
end

function mode(m, append)
 return function (count)
  if m ~= 'c' and m ~= 'n' then
   splash=false
  end

  local append_size=min(max_pos('x', 'n'), 1)
  local append_value=append and append_size - 1 or -1

  mod=m

  if m == 'n' and cur_input.restore_cursor then
   move_cursor('c', max(1, cur_input.insertion + append_value), true)(count)
  end

  cur_input=input[mod] or {text=''}
  cur_input.insertion = nil
  if cur_input.text ~= nil then
   cur_input.text = ''
  end
  if m == 'i' then
   cur_input.insertion = pos.c + append_value
   pos.c = cur_input.insertion + 1
  end
 end
end

function move_cursor(k, offset, absolute)
 local function move_input(count)
  if k == 'l' then
   local ins_pos = cur_input.insertion
   mode('n', true)(0)
   move_cursor('l', offset)(count)
   mode('i', true)(0)
   cur_input.insertion = ins_pos
   move_cursor('c', 0)(0)
  else
   local input_text=cur_input.text or cur_input.input() or ''
   local input_len=#input_text
   local new_offset=count > 0 and (count * offset) or offset
   local new_value=(cur_input.insertion or input_len) + new_offset
   if new_value < 0 then
    cur_input.insertion = 0
   elseif new_value > input_len then
    cur_input.insertion = input_len
   else
    cur_input.insertion = new_value
   end
   if mod == 'i' then
    pos.c = cur_input.insertion + 1
   end
  end
 end

 return function (count)
  if mod ~= 'n' then
   return move_input(count)
  end

  local new_value=pos[k] + (count > 0 and (count * offset) or offset)
  local max_value=max_pos(k)
  if absolute then
   if count > 0 then
    pos[k]=count
   else
    pos[k]=offset
   end
  elseif new_value > 0 and new_value <= max_value then
   pos[k]=new_value
  elseif new_value > max_value and max_value > 0 then
   pos[k]=max_value
  else
   pos[k]=1
  end

  if pos[k] < 1 then
   if k == 'l' then
    pos.l=#lines
   else
    pos.c=#(lines[pos.l] or '')
   end
  end

  if k == 'l' then
   local so=min(opts.so, flr(max_disp_line[mod] / 2))
   if pos.y + so > pos.l then
    pos.y=max(1, pos.l - so)
   elseif pos.y + max_disp_line[mod] - so <= pos.l then
    pos.y=pos.l - max_disp_line[mod] + 1 + so
   end

   move_cursor('c', 0)(count)
  end
 end
end

function scroll(k, offset)
 return function (count)
  local new_value=pos[k] + (count > 0 and (count * offset) or offset)
  local max_value=max_pos(k)
  if new_value > 0 and new_value <= max_value then
   pos[k]=new_value
  elseif new_value > max_value then
   pos[k]=max_value
  else
   pos[k]=1
  end

  local so=min(opts.so, flr(max_disp_line[mod] / 2))
  if pos.y + so > pos.l then
   pos.l=min(pos.y + so, max_value)
  elseif pos.y + max_disp_line[mod] - so <= pos.l then
   pos.l=pos.y + max_disp_line[mod] - 1 - so
  end
 end
end
