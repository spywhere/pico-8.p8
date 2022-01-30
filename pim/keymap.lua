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
   ['<c-c>']=mode('n'),
   ['<left>']=move_cursor('c', -1),
   ['<right>']=move_cursor('c', 1)
  },
  n={
   ['<c-c>']=clr_key_seq,
   [':']=mode('c'),
   i=mode('i'),
   I=compose {
    move_cursor('c', 1, true),
    mode('i')
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
    function () cur_input.accept() end
   },
   O=compose {
    move_cursor('c', 1, true),
    mode('i'),
    function () cur_input.accept() end,
    move_cursor('l', -1)
   },
   p=motion_cmd(print_range, 'd')
  }
 }
end
