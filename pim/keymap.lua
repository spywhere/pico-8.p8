function _keymap()
 keymap = function (opts)
  if opts.input == 'keypad' then
   return {
    i={
     ['<tab>']=mode('n', true),
     ['<left>']=move_cursor('c', -1),
     ['<right>']=move_cursor('c', 1),
     ['<up>']=incdec(1),
     ['<down>']=incdec(-1)
    },
    c={
     ['<left>']=move_cursor('c', -1),
     ['<right>']=move_cursor('c', 1),
     ['<up>']=incdec(1),
     ['<down>']=incdec(-1)
    },
    v={
     -- ['<enter>']=  -- yank
     ['<lf>']=mode('c'),
     ['<bsp>']=mode('n', true)
     -- ['<tab>']=  -- change
    },
    n={
     ['<enter>']=mode('i'),
     ['<lf>']=mode('i', true),
     ['<bsp>']=mode('c'),
     ['<tab>']=mode('v')
    }
   }
  end

  return {
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
    ['<right>']=move_cursor('c', 1),
    ['<up>']=history(1),
    ['<down>']=history(-1)
   },
   v={
    ['<c-c>']=mode('n'),
    [':']=mode('c'),
    v=mode('v'),
    V=mode('vl'),
    ['<c-v>']=mode('vb'),
    o=swap_anchor,
    O=swap_anchor,
    p=motion_cmd(print_range, 'd')
   },
   n={
    ['<c-c>']=clr_key_seq,
    [':']=mode('c'),
    v=mode('v'),
    V=mode('vl'),
    ['<c-v>']=mode('vb'),
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
end
