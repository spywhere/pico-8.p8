function _highlight()
 hl={
  cursor=by_mode {
   6,
   n=7,
   c=7
  },
  status=by_mode {
   6,
   n=7
  },
  message=by_key {
   0,
   error=8
  },
  mode=by_mode {
   7
  },
  sign=by_key {
   7,
   linenumber=9,
   eob=12
  },
  visual=by_mode {
   6
  }
 }
end

function by_key(map)
 return function (key)
  return map[key] or map[1]
 end
end

function by_mode(mode_map)
 return function ()
  return mode_map[mod] or mode_map[1]
 end
end
