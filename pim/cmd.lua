function _cmd()
 cmds={
  set=set,
  quit=function ()
   extcmd('pause')
  end
 }
 cmds.q=cmds.quit
 cmds.quitall=cmds.quit
 cmds.qa=cmds.quit
end
