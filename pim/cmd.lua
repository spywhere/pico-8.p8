function _cmd()
 cmds={
  set=set,
  edit=function (option)
   -- TODO: bang: revert to original content (before write)

   if not stat(const.has_file) then
    return
   end
   local new_lines=read_drop_file()

   if new_lines then
    set_lines(0, new_lines, #option > 0 and option[1] or nil)
   else
    error('file is not a text file')
   end
  end,
  quit=function ()
   extcmd('pause')
  end
 }
 cmds.e=cmds.edit
 cmds.q=cmds.quit
 cmds.quitall=cmds.quit
 cmds.qa=cmds.quit
end
