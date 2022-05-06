function mode(new_mode, append)
 return function (count)
  local m=new_mode
  if m ~= 'c' and m ~= 'n' then
   splash=false
  end

  local append_size=min(max_pos('x', 'n'), 1)
  local append_value=append and append_size - 1 or -1

  local last_mod=mod
  local last_visual=sub(last_mod, 1, 1) == 'v'

  if last_visual and last_mod == m then
   m='n'
  end

  mod=m

  if m == 'n' then
   if mouse then
    mouse.hide = false
   end

   if cur_input.restore_cursor then
    move_cursor('c', max(1, cur_input.insertion + append_value), true)(0)
   else
    move_cursor('c', 0)(0)
   end
  end

  if not last_visual and sub(m, 1, 1) == 'v' then
   anchor_pos = { c=pos.c, l=pos.l }
  end

  cur_input=input[mod] or {text=''}
  cur_input.insertion = nil
  if cur_input.text ~= nil then
   cur_input.text = last_visual and '\'<,\'>' or ''
  end
  if m == 'i' then
   cur_input.insertion = pos.c + append_value
   pos.c = cur_input.insertion + 1
  end
 end
end

function swap_anchor()
 anchor_pos.l, pos.l = pos.l, anchor_pos.l
 anchor_pos.c, pos.c = pos.c, anchor_pos.c
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
  if mod == 'i' or mod == 'c' then
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
    pos.l=max_value
   else
    pos.c=max(1, max_value)
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

function incdec(direction)
 local function next_char(num, direction)
  -- 32 - 126
  local jmp = {
   [32] = { -- SPC
    [-1] = 90,
    [1] = 97
   },
   [48] = { -- 0
    [-1] = 122
   },
   [64] = { -- @
    [1] = 91
   },
   [65] = { -- A
    [-1] = 126
   },
   [90] = { -- Z
    [1] = 32
   },
   [91] = { -- [
    [-1] = 64
   },
   [96] = { -- `
    [1] = 123
   },
   [97] = { -- a
    [-1] = 32
   },
   [122] = { -- Z
    [1] = 48
   },
   [123] = {
    [-1] = 96
   },
   [126] = { -- ~
    [1] = 65
   }
  }

  if jmp[num] and jmp[num][direction] then
   return chr(jmp[num][direction])
  else
   return chr(num + direction)
  end
 end

 return function (count)
  local source=cur_input.text or cur_input.input()
  local insertion=cur_input.insertion or #source
  cur_input.insertion = insertion

  local char = sub(source, insertion + 1, insertion + 1)
  if char == '' and direction > 0 then
   char = ' '
  elseif (char == '' or char == ' ') and direction < 0 then
   char = ''
  else
   char = next_char(ord(char), direction)
  end

  source = sub(source, 1, insertion) .. char .. sub(source, insertion + 2)

  if cur_input.input then
   cur_input.input(source)
  else
   cur_input.text = source
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

function history(direction)
 return function ()
  local source=cur_input.text or cur_input.input()

  if history_idx ~= 0 and source ~= cmd_history[history_idx] then
   return
  end

  source = cmd_history[history_idx + direction]
  if history_idx + direction == 0 then
   source = ''
  elseif not source then
   return
  end

  if cur_input.input then
   cur_input.input(source)
  else
   cur_input.text = source
  end
  cur_input.insertion = #source

  history_idx += direction
 end
end

function print_range(range)
 info(
  (range.line and 'line ' or '')..
  (range.block and 'block ' or '')..
  'range to '..
  tostr(range.to.c) .. ':' .. tostr(range.to.l)
 )
end
