function compose(cmds)
 return function (count)
  foreach(cmds, function (f) f(0) end)
 end
end


function set(option)
 local val=true
 local view=false

 if #option < 1 then
  error('e518: unknown option')
  return
 end

 local components=split(option[1], '=')
 local name=components[1]

 if sub(name, #name, #name) == '?' then
  name=sub(name, 1, #name-1)
  view=true
 end
 if sub(name, 1, 2) == 'no' then
  name=sub(name, 3)
  val=false
 end

 local value=components[2]
 local original_name=name

 if opts[name] == nil then
  name = opts_alias[name]
 end

 if opts[name] == nil then
  error('e518: unknown option')
  return
 end

 local value_type=type(opts[name])

 if value_type == 'number' then
  if not val or value and tonum(value) then
   val=val and tonum(value) or 0
  else
   view=true
  end
 end

 if view then
  if value_type == 'number' then
   info('  '..original_name..'='..tostr(opts[name]))
  else
   info((opts[name] and '  ' or 'no')..original_name)
  end
   return
 end
 opts[name]=val
end
