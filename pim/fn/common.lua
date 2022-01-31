function compose(cmds)
 return function (count)
  foreach(cmds, function (f) f(0) end)
 end
end
