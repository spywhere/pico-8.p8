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
    error('e212: file is not a text file')
   end
  end,
  write=function (option)
   local buffer=buffer_at(0)
   local filename=#option > 0 and (option[1] .. const.file_suffix) or buffer.name
   if not filename or filename == '' then
    error('e32: no file name')
    return
   end

   local numline=#buffer.lines
   local numch=0

   for line in all(buffer.lines) do
    printh(line, filename, numch == 0)
    numch+=#line+1
   end

   buffer.name = filename
   info('"'..buffer.name..'" '..tostr(numline)..'l, '..tostr(numch)..'c written')
  end,
  quit=function ()
   extcmd('pause')
  end
 }
 cmds.e=cmds.edit
 cmds.w=cmds.write
 cmds.q=cmds.quit
 cmds.quitall=cmds.quit
 cmds.qa=cmds.quit
end
