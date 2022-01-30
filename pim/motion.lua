function _motion()
 motion={
  ['']=function(opts, char)
   -- between a character
  end,
  h=to_char(-1),
  j=to_line(1),
  k=to_line(-1),
  l=to_char(1),
  ['<left>']=to_char(-1),
  ['<down>']=to_line(1),
  ['<up>']=to_line(-1),
  ['<right>']=to_char(1),
  ['<c-b>']=to_line(-20),
  ['<c-f>']=to_line(20),
  ['<c-d>']=to_line(10),
  ['<c-u>']=to_line(-10),
  g={
   _=to_line(),
   g=to_line(1, true)
  },
  G=to_line(0, true),
  ['0']=to_char(1, true),
  ['$']=to_char(0, true)
 }
end
