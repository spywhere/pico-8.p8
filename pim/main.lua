-- pim v0.1.0
-- by spywhere
version='0.1.0'
mod='n'
modes={}
lines={}
opts={
 debug=false,
 nu=false,
 rnu=false,
 so=0,
 tm=1000
}
opts_alias={
 number='nu',
 relativenumber='rnu',
 scrolloff='so',
 timeoutlen='tm'
}
max_disp_line={
 n=20,
 i=21,
 c=20
}
pos={x=1,y=1,c=1,l=1}
last_message=0
message=nil
messagehl=0
last_key=0
key_count=0
cur_kmap=nil
key=0
cur_input={text=''}
splash=false
cmds={}
input={}
keymap={}

function _init()
 -- enable mouse and keyboard
 poke(0x5f2d, 1)

 modes={
  i='--insert--',
  c=''
 }
 lines=split('', '\n')
 splash=#lines == 0 or #lines[1] == 0

 cmds={
  set=set,
  quit=function ()
   extcmd('pause')
  end
 }
 cmds.q=cmds.quit
 cmds.quitall=cmds.quit
 cmds.qa=cmds.quit

 input={
  i={
   input=function (value)
    if value then
     lines[pos.l] = value
     pos.c = cur_input.insertion + 1
    end

    return lines[pos.l]
   end,
   back_on_first=true,
   restore_cursor=true,
   back=function ()
    if pos.l <= 1 then
     return
    end
    local new_insertion=#lines[pos.l - 1]
    lines[pos.l - 1] = lines[pos.l - 1] .. lines[pos.l]
    deli(lines, pos.l)
    move_cursor('l', -1)(0)
    mode('i', false)(0)
    cur_input.insertion = new_insertion
   end,
   accept=function ()
    local new_line=sub(lines[pos.l], cur_input.insertion + 1)
    lines[pos.l] = sub(lines[pos.l], 1, cur_input.insertion)
    add(lines, new_line, pos.l + 1)
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

 _keymap()
end

function max_pos(k, override_mode)
 if k == 'l' or k == 'y' then
  return #lines
 else
  return #(lines[pos.l] or '') + ((override_mode or mod) == 'i' and 1 or 0)
 end
end

function clr_key_seq(notify)
 if notify and last_key == 0 then
  info('type :qa then <enter> to exit')
 end

 key=0
 last_key=0
 key_count=0
 cur_kmap=nil
end

function info(msg)
 last_message=time()+2
 message=msg
 messagehl=0
end

function error(msg)
 info(msg)
 messagehl=8
end

function eval_cmd(input, cmd_seq, cmdset)
 if type(cmdset) ~= 'table' or #cmd_seq <= 0 then
  error('e492: not an editor cmd')
  return
 end

 local name=cmd_seq[1]
 del(cmd_seq, name)
 local value=cmdset[name]

 if type(value) == 'function' then
  return value(cmd_seq)
 else
  return eval_cmd(input, cmd_seq, value)
 end
end

function is_printable(num)
 return
  (num >= 8 and num <= 10) or
  num == 13 or
  (num >= 32 and num <= 126) or
  (num >=128 and num <= 153)
end

function kch(num)
 if num == 0 then
  return ''
 elseif num == 8 then
  return '<bsp>'
 elseif num == 9 then
  return '<tab>'
 elseif num == 10 then
  return '<lf>'
 elseif num == 13 then
  return '<enter>'
 elseif num == 32 then
  return '<spc>'
 elseif num > 32 and num <= 126 then
  return chr(num)
 elseif num >= 128 and num <= 153 then
  return chr(num-63)
 elseif num >= 192 and num <= 217 then
  return '<c-'..chr(num-95)..'>'
 elseif num == 995 then
  return '<left>'
 elseif num == 996 then
  return '<right>'
 elseif num == 997 then
  return '<up>'
 elseif num == 998 then
  return '<down>'
 else
  return tostr(num)
 end
end

function printr(str, x, y, col)
 local cx=128-(4*#str)-x
 print(str, cx, y, col)
end

function lpad_match(str, target, c)
 if #str < #target then
  return lpad_match((c or ' ') .. str, target, c)
 else
  return str
 end
end

function _draw()
 cls(0)

 if opts.debug then
  printr('#lines='..#lines, 0, 0, 7)
  printr('nu='..tostr(opts.nu), 0, 6, 7)
  printr('rnu='..tostr(opts.rnu), 0, 12, 7)
  printr('so='..tostr(opts.so), 0, 18, 7)
  printr('key='..kch(key), 0, 24, 7)
  printr('pos='..tostr(pos.c)..':'..tostr(pos.l), 0, 30, 7)
 end

 if splash then
  print('pim v'..version, 48, 36, 7)
  print('pim is vim-like editor', 24, 48, 7)
  print('for pico-8', 48, 54, 7)
  print('type i  to start editing', 20, 66, 7)
  print('type :q to pause and exit', 20, 72, 7)
 end

 local max_lines = max_pos('y')
 local pad_max = max_lines < 10 and 10 or max_lines
 local sign_size = (opts.nu or opts.rnu) and (#tostr(pad_max) + 1) * 4 or 1

 for idx=0, max_disp_line[mod] - 1 do
  local lineno=pos.y + idx

  -- sign
  local sign=''
  local signhl=12
  if lineno <= max_lines then
   if opts.nu or opts.rnu then
    local lno=lineno
    if not opts.nu or (opts.rnu and pos.l ~= lineno) then
     lno=abs(pos.l - lineno)
    end
    sign=lpad_match(tostr(lno), tostr(pad_max))
    if opts.nu and opts.rnu and pos.l == lineno then
     sign=tostr(lno)
    end
    signhl=9
   end

   -- line content
   local lx = sign_size
   local ly = idx * 6
   print(sub(lines[lineno], 1, 64 - sign_size / 4), lx, 1 + ly, 7)
  else
   sign='~'
  end

  print(sign, 0, 1 + idx * 6, signhl)
 end

 -- cmd/status line
 if mod == 'i' then
  printr(modes[mod], 0, 122, 7)
 else
  rectfill(0, 121, 127, 127, mod == 'n' and 7 or 6)

  if mod == 'n' then
   if message then
    print(message, 1, 122, messagehl)
   else
    printr(kch(key)..' '..tostr(pos.c)..':'..tostr(pos.l), 0, 122, 0)
   end
  else
   print(':' .. cur_input.text, 1, 122, 0)
  end
 end

 -- cursor
 local cx = (pos.c - pos.x) * 4 + sign_size
 local cy = (pos.l - pos.y) * 6
 local cch = pos.c <= #lines[pos.l] and sub(lines[pos.l] or '', pos.c, pos.c) or ''

 if mod == 'c' or mod == 'i' then
  if mod == 'c' then
   sign_size=5
   cy=121
  end

  local text=cur_input.text or cur_input.input()

  local ip=cur_input.insertion or #text
  cx=ip * 4 + sign_size
  cch=ip < #text and sub(text, ip + 1, ip + 1) or ''
 end

 rectfill(cx - 1, cy, cx + 3, cy + 6, mod == 'c' and 7 or 6)
 print(cch, cx, cy + 1, 0)
end

function eval_key_seq()
 local k=kch(key)

 if cur_kmap == nil then
  if mod == 'i' or mod == 'c' then
   if is_printable(key) then
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
  elseif mod == 'n' then
   if key >= 48 and key <= 57 then
    if key_count > 0 then
     key_count = key_count * 10
    end
    key_count=key_count + key - 48
    if key_count > 0 then
     return true
    end
   end
  end
 end

 local map_type=type(cur_kmap)
  if cur_kmap == nil then
   cur_kmap=keymap[mod][k]
  elseif map_type == 'table' then
   cur_kmap=cur_kmap[k]
  end

 map_type=type(cur_kmap)
 if map_type == 'function' then
  -- map to function
  cur_kmap = cur_kmap(key_count) or nil
  return cur_kmap and true or false
 elseif map_type == 'table' then
  -- more map to be evaluate
  return true
 else
  return false
 end
end

function _update()
 if mod == 'n' and last_key > 0 and last_key < time() then
  key=0
  eval_key_seq()
  clr_key_seq()
 end

 local k=nil
 -- if key press
 if stat(30) then
  -- get key code
  k=ord(stat(31))

  if k == 13 or k == 112 then
   -- disable pause menu for Return and P key
   poke(0x5f30, 1)
  end
 elseif btnp(0) then
  k=995 -- special code for left arrow
 elseif btnp(1) then
  k=996 -- special code for right arrow
 elseif btnp(2) then
  k=997 -- special code for up arrow
 elseif btnp(3) then
  k=998 -- special code for down arrow
 end

 if k ~= nil then
  key=k
  if eval_key_seq() then
   last_key=time() + (opts.tm / 1000)
  else
   clr_key_seq()
  end
 end

 if last_message > 0 and last_message < time() then
  last_message=0
  message=nil
  messagehl=0
 end
end
