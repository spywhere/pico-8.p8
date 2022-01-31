function read_drop_file()
 local lines={}
 local line=''
 while stat(const.has_file) do
  serial(const.dropped_file, const.userdata, 1)
  local data=peek(const.userdata)
  local char=chr(data)

  if char == '\n' then
   add(lines, line)
   line=''
  elseif char == '\0' then
   break
  elseif is_printable(data) then
   line=line..char
  else
   -- unexpected range of character code
   -- probably reading a binary file
   return nil
  end
 end

 if #line > 0 then
  add(lines, line)
 end

 return lines
end
