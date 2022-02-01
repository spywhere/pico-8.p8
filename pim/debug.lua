function draw_debug()
 if opts.debug == '' then
  return
 end

 printr('#lines='..lines(0), 0, 0, 7)
 local idx=6
 for k in all(split(opts.debug, ',', false)) do
  if opts[k] ~= nil then
   printr(k..'='..tostr(opts[k]), 0, idx, 7)
   idx+=6
  end
 end
 printr('key='..kch(key), 0, idx, 7)
 printr('pos='..tostr(pos.c)..':'..tostr(pos.l), 0, idx+6, 7)
 if anchor_pos then
  printr('apos='..tostr(anchor_pos.c)..':'..tostr(anchor_pos.l), 0, idx+12, 7)
 end
end
