function _input()
 input={
  i={
   input=function (value)
    if value then
     line_at(0, pos.l, value)
     pos.c = cur_input.insertion + 1
    end

    return line_at(0, pos.l)
   end,
   back_on_first=true,
   restore_cursor=true,
   back=function ()
    if pos.l <= 1 then
     return
    end
    local new_insertion=#line_at(0, pos.l - 1)
    line_at(0, pos.l - 1, line_at(0, pos.l - 1) .. line_at(0, pos.l))
    set_line_at(0, pos.l)
    move_cursor('l', -1)(0)
    mode('i', false)(0)
    cur_input.insertion = new_insertion
   end,
   accept=function ()
    local new_line=sub(line_at(0, pos.l), cur_input.insertion + 1)
    line_at(0, pos.l, sub(line_at(0, pos.l), 1, cur_input.insertion))
    set_line_at(0, pos.l + 1, new_line)
    move_cursor('l', 1)(0)
    mode('i', false)(0)
    cur_input.insertion = 0
   end
  },
  c={
   text='',
   back=mode('n', false),
   accept=function ()
    if input ~= '' then
     local text=cur_input.text

     -- remove bang
     if sub(text, #text, #text) == '!' then
      text=sub(text, 1, #text-1)
     end

     local cmd_seq=split(text, ' ')
     eval_cmd(cur_input.text, cmd_seq, cmds)
    end
    mode('n', false)(0)
   end
  }
 }
end

function is_printable(num)
 return
  (num >= 8 and num <= 10) or
  num == 13 or
  (num >= 32 and num <= 126) or
  (num >=128 and num <= 153)
end

function handle_input(k)
 if not is_printable(key) then
  return true
 end

 local source=cur_input.text or cur_input.input()
 local ins=''
 -- backspace
 if k == '<bsp>' then
  local insertion=cur_input.insertion or #source
  if source == '' or insertion <= 0 then
   if source == '' or cur_input.back_on_first then
    cur_input.back()
   end
   return false
  end

  local front = sub(source, 1, insertion - 1)
  local back = insertion < #source and sub(source, insertion+1, #source) or ''
  cur_input.insertion=insertion - 1
  source=front .. back
 elseif k == '<enter>' or k == '<tab>' then
  cur_input.accept()
  return false
 elseif k == '<spc>' then
  ins=' '
 elseif #k == 1 then
  ins=k
 end

 if ins ~= '' then
  local insertion=cur_input.insertion or #source
  local front = sub(source, 1, insertion)
  local back = insertion < #source and sub(source, insertion+1, #source) or ''
  cur_input.insertion=insertion + 1

  source=front .. ins .. back
 end

 if cur_input.input then
  cur_input.input(source)
 else
  cur_input.text = source
 end

 return false
end

function handle_count()
 if key < 48 or key > 57 then
  return false
 end

 if key_count > 0 then
  key_count = key_count * 10
 end

 key_count=key_count + key - 48

 if key_count > 0 then
  return true
 end
end
