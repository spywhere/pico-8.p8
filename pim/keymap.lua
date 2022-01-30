function _keymap()
 keymap={
  i={
   ['<c-c>']=mode('n', true),
   ['<left>']=move_cursor('c', -1),
   ['<right>']=move_cursor('c', 1),
   ['<up>']=move_cursor('l', -1),
   ['<down>']=move_cursor('l', 1)
  },
  c={
   ['<c-c>']=mode('n', false),
   ['<left>']=move_cursor('c', -1),
   ['<right>']=move_cursor('c', 1)
  },
  n={
   ['<c-c>']=clr_key_seq,
   [':']=mode('c', false),
   i=mode('i', false),
   I=compose {
    move_cursor('c', 1, true),
    mode('i', false)
   },
   a=mode('i', true),
   A=compose {
    move_cursor('c', 0, true),
    mode('i', true)
   },
   ['<c-e>']=scroll('y', 1),
   ['<c-y>']=scroll('y', -1),
   o=compose {
    move_cursor('c', 0, true),
    mode('i', true),
    cur_input.accept
   },
   O=compose {
    move_cursor('c', 1, true),
    mode('i'),
    cur_input.accept,
    move_cursor('l', -1)
   },
   p=motion_cmd(print_range, 'd')
  }
 }
end
