function _option()
 opts={
  -- pim-related options
  debug='',
  input='',
  -- vim-related options
  nu=false,
  rnu=false,
  so=0,
  tm=1000,
  mouse='',
  isk=charset { { 65, 90 }, { 97, 122 }, { 48, 57 }, '_' }
 }
 opts_alias={
  number='nu',
  relativenumber='rnu',
  scrolloff='so',
  timeoutlen='tm',
  iskeyword='isk'
 }

 modes={
  i='--insert--',
  c='',
  v='--visual--',
  vl='--visual line--',
  vb='--visual block--'
 }
end

function set(option)
 local val=true
 local view=false

 if #option < 1 then
  error('e518: unknown option')
  return
 end

 local components=split(option[1], '=', false)
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
 elseif value_type == 'string' then
  val=val and value or ''
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

