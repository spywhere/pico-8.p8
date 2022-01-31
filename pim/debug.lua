function draw_debug()
 if not opts.debug then
  return
 end

 printr('#lines='..lines(0), 0, 0, 7)
 printr('nu='..tostr(opts.nu), 0, 6, 7)
 printr('rnu='..tostr(opts.rnu), 0, 12, 7)
 printr('so='..tostr(opts.so), 0, 18, 7)
 printr('key='..kch(key), 0, 24, 7)
 printr('pos='..tostr(pos.c)..':'..tostr(pos.l), 0, 30, 7)
 if anchor_pos then
  printr('apos='..tostr(anchor_pos.c)..':'..tostr(anchor_pos.l), 0, 36, 7)
 end
end
