function _buffer()
 buffers={
  {
   lines={''}
  }
 }
 cur_buffer=1
end

function _bufid(buffer_id)
 return buffer_id and buffer_id > 0 and buffer_id or cur_buffer
end

function buffer_at(buffer_id)
 return buffers[_bufid(buffer_id)] or { lines={} }
end

function is_empty_buffer(buffer_id)
 local lines=buffer_at(buffer_id).lines
 return #lines == 0 or #lines[1] == 0
end

function lines(buffer_id)
 return #buffer_at(buffer_id).lines
end

function line_at(buffer_id, line_number, content)
 local buffer=buffers[_bufid(buffer_id)]
 if content == nil then
  return (buffer or { lines={} }).lines[line_number]
 else
  buffer.lines[line_number] = content
 end
end

function set_line_at(buffer_id, line_number, content)
 local buffer=buffers[_bufid(buffer_id)]
 if content == nil then
  deli(buffer.lines, line_number)
 else
  add(buffer.lines, content, line_number)
 end
end
