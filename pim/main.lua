-- pim v0.3.1
-- by spywhere
version='0.3.1'
const={
 devkit=0x5f2d,
 pause_menu=0x5f30,
 dropped_file=0x800,
 userdata=0x4300,
 keypress=30,
 keycode=31,
 mousex=32,
 mousey=33,
 mousescroll=36,
 mouseaccel=37,
 has_file=120,
 size=128,
 chwidth=32,
 file_suffix='.p8l',
 blank_chars='\t '
}
mod='n'
modes={}
buffers={}
cmd_history={}
history_idx=0
opts={}
opts_alias={}
max_disp_line={
 n=20,
 i=21,
 v=21,
 vl=21,
 vb=21,
 c=20
}
pos={x=1,y=1,c=1,l=1}
anchor_pos={c=1,l=1}
message=nil
last_key=0
key_count=0
cur_map=nil
key=0
last_mouse=nil
mouse=nil
cur_input={text=''}
splash=false
file_dropped=false
cmds={}
input={}
motion=function () return {} end
keymap=function () return {} end
hl={}

function _init()
 _option()

 switch_input()

 _buffer()
 splash=is_empty_buffer(0)

 _cmd()
 _input()
 _motion()
 _keymap()
 _highlight()
end

function max_pos(k, override_mode)
 local target_mode = override_mode or mod
 local is_edit = target_mode == 'i' or sub(target_mode, 1, 1) == 'v'
 if k == 'l' or k == 'y' then
  return lines(0)
 else
  return #(line_at(0, pos.l) or '') + (is_edit and 1 or 0)
 end
end

function clr_key_seq(notify)
 if notify and last_key == 0 then
  info('type :qa then <enter> to exit')
 end

 key=0
 last_key=0
 key_count=0
 cur_map=nil
end

function info(msg)
 message={
  type='info',
  text=msg,
  timeout=time()+2
 }
end

function error(msg)
 message={
  type='error',
  text=msg,
  timeout=time()+2
 }
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
 local cx=const.size-(4*#str)-x
 print(str, cx, y, col)
end

function lpad_match(str, target, c)
 if #str < #target then
  return lpad_match((c or ' ') .. str, target, c)
 else
  return str
 end
end

function get_key_count(table, under_n)
 local count = 0
 for k in pairs(table) do
  if type(k) == 'string' then
   count += 1
  end

  if under_n and count > under_n then
   return count
  end
 end

 return count
end

function get_fn_or_table(value)
 local value_type=type(value)
 if value_type == 'function' then
  return value
 elseif value_type == 'table' then
  local key_count = get_key_count(value, 1)
  if key_count == 0 then
   return nil
  elseif key_count == 1 and value[''] then
   return value['']
  else
   return value
  end
 else
  return nil
 end
end

function eval_key_seq()
 local k=kch(key)
 local m=sub(mod, 1, 1)

 if cur_map == nil then
  local is_devkit = opts.input == 'devkit'
  if input[m] and not handle_input(k, is_devkit) then
   return false
  elseif handle_count() then
   return true
  end
 end

 local map_type=type(cur_map)
 if cur_map == nil then
  cur_map={
   k=keymap(opts)[m][k],
   m=motion(opts)[k]
  }
 else
  cur_map={
   k=(cur_map.k or {})[k],
   m=(cur_map.m or {})[k]
  }
 end

 local kmap = get_fn_or_table(cur_map.k)
 local mmap = get_fn_or_table(cur_map.m)
 local kmap_type=type(kmap)
 local mmap_type=type(mmap)
 if kmap_type == 'function' then
  -- map to keymap function
  cur_map = kmap(key_count) or nil
  return cur_map and true or false
 elseif mmap_type == 'function' then
  -- map to motion function
  local range = mmap({ modifier='', count=key_count }) or nil
  if range then
   if pos.l ~= range.to.l then
    move_cursor('l', range.to.l, true)(0)
   end
   if pos.c ~= range.to.c then
    move_cursor('c', range.to.c, true)(0)
   end
  end
  return false
 elseif kmap_type == 'table' or mmap_type == 'table' then
  -- more map to be evaluate
  return true
 else
  return false
 end
end

function _draw()
 cls(0)

 draw_debug()

 if splash then
  print('pim v'..version, 48, 36, 7)
  print('pim is vim-like editor', 24, 48, 7)
  print('for pico-8', 48, 54, 7)
  print('type i   to start editing', 16, 66, 7)
  print('type :q  to pause and exit', 16, 72, 7)
  print('pause to change input mode', 16, 84, 7)
 end

 local max_lines = max_pos('y')
 local pad_max = max_lines < 10 and 10 or max_lines
 local sign_size = (opts.nu or opts.rnu) and (#tostr(pad_max) + 1) * 4 or 1

 local min_l, max_l, from_c, to_c = 1, 1, 1, 1
 if pos.l < anchor_pos.l then
  min_l = pos.l
  max_l = anchor_pos.l
  from_c = pos.c
  to_c = anchor_pos.c
 else
  min_l = anchor_pos.l
  max_l = pos.l
  from_c = anchor_pos.c
  to_c = pos.c
 end
 if mod == 'vb' then
  from_c, to_c = min(pos.c, anchor_pos.c), max(pos.c, anchor_pos.c)
 end

 for idx=0, max_disp_line[mod] - 1 do
  local lineno=pos.y + idx

  -- sign
  local sign={text='', type='eob'}
  if lineno <= max_lines then
   if opts.nu or opts.rnu then
    sign.type='linenumber'
    local lno=lineno
    if not opts.nu or (opts.rnu and pos.l ~= lineno) then
     lno=abs(pos.l - lineno)
    end
    sign.text=lpad_match(tostr(lno), tostr(pad_max))
    if opts.nu and opts.rnu and pos.l == lineno then
     sign.text=tostr(lno)
    end
   end

   -- line content
   local lx = sign_size
   local ly = idx * 6
   -- visual highlight
   if sub(mod, 1, 1) == 'v' and lineno >= min_l and lineno <= max_l then
    local line_len = #line_at(0, lineno)
    local fx = (lineno == min_l and from_c or 1) - 1
    local tx = (lineno == max_l and to_c - 1 or line_len)
    if mod == 'vl' then
     fx = 0
     tx = line_len
    elseif mod == 'vb' then
     fx = from_c - 1
     tx = min(to_c - 1, line_len)
    end

    if fx <= line_len then
     rectfill(lx - 1 + fx * 4, ly, lx + 3 + tx * 4, ly + 6, hl.visual())
    end
   end
   print(sub(line_at(0, lineno), 1, const.chwidth - flr(sign_size / 4)), lx, 1 + ly, 7)
  else
   sign.text='~'
  end

  print(sign.text, 0, 1 + idx * 6, hl.sign(sign.type))
 end

 -- cmd/status line
 if mod == 'n' or mod == 'c' then
  rectfill(0, 121, 127, 127, hl.status())

  if mod == 'n' then
   if message then
    print(message.text, 1, 122, hl.message(message.type))
   else
    print(buffer_at(0).name or '[no name]', 1, 122, 0)
    printr(kch(key)..' '..tostr(pos.c)..':'..tostr(pos.l), 0, 122, 0)
   end
  else
   print(':' .. cur_input.text, 1, 122, 0)
  end
 else
  printr(modes[mod], 0, 122, hl.mode())
 end

 -- cursor
 local cx = (pos.c - pos.x) * 4 + sign_size
 local cy = (pos.l - pos.y) * 6
 local cch = pos.c <= #line_at(0, pos.l) and sub(line_at(0, pos.l) or '', pos.c, pos.c) or ''

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

 rectfill(cx - 1, cy, cx + 3, cy + 6, hl.cursor())
 print(cch, cx, cy + 1, 0)

 -- mouse cursor
 if mouse and not mouse.hide then
  spr(0, mouse.x, mouse.y)
 end
end

function _update()
 local m=sub(mod, 1, 1)
 if (m == 'n' or m == 'v') and last_key > 0 and last_key < time() then
  key=0
  eval_key_seq()
  clr_key_seq()
 end

 local k=nil

 if opts.input == 'keypad' then
  if btnp(0, 0) or btnp(0, 1) then
   k=995 -- special code for left arrow
  elseif btnp(1, 0) or btnp(1, 1) then
   k=996 -- special code for right arrow
  elseif btnp(2, 0) or btnp(2, 1) then
   k=997 -- special code for up arrow
  elseif btnp(3, 0) or btnp(3, 1) then
   k=998 -- special code for down arrow
  elseif btnp(4, 0) then
   k=8   -- use <bsp> code for 1st player O button
  elseif btnp(5, 0) then
   k=13  -- use <enter> code for 1st player X button
  elseif btnp(4, 1) then
   k=9   -- use <tab> code for 2nd player O button
  elseif btnp(5, 1) then
   k=10  -- use <lf> code for 2nd player X button
  end
 elseif opts.input == 'devkit' then
  if stat(const.keypress) then
   k=ord(stat(const.keycode))

   if k == 13 or k == 112 then
    -- disable pause menu for Return and P key
    poke(const.pause_menu, 1)
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

  local mx = stat(const.mousex)
  local my = stat(const.mousey)
  local mouse_on = opts.mouse == 'a' or opts.mouse == m
  if mouse_on and (not mouse or mouse.x ~= mx or mouse.y ~= my) then
   mouse = { x=mx, y=my }
  elseif not mouse_on and mouse then
   mouse = nil
  end

  local mouse_scroll = stat(const.mousescroll)
  if mouse_scroll ~= 0 then
   scroll('l', mouse_scroll)(0)
  end
 end

 local has_dropped=file_dropped
 file_dropped=stat(const.has_file)
 if not has_dropped and file_dropped then
  info('type :e then enter to read it')
 end

 if k ~= nil then
  key=k
  if eval_key_seq() then
   last_key=time() + (opts.tm / 1000)
  else
   clr_key_seq()
  end
 end

 if message and message.timeout < time() then
  message=nil
 end
end
