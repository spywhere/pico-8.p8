function _motion()
 motion={
  ['']=function(opts, char)
   -- between a character
  end,
  g={
   _=to_line(),
   g=to_line(1, true)
  },
  G=to_line(0, true),
  j=to_line(1),
  k=to_line(-1),
  ['<down>']=to_line(1),
  ['<up>']=to_line(-1),
  ['<c-b>']=to_line(-20),
  ['<c-f>']=to_line(20),
  ['<c-d>']=to_line(10),
  ['<c-u>']=to_line(-10)
 }
end
