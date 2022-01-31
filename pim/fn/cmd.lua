function eval_cmd(input, cmd_seq, cmdset)
 if type(cmdset) ~= 'table' or #cmd_seq <= 0 then
  error('e492: not an editor cmd')
  return
 end

 local name=cmd_seq[1]
 del(cmd_seq, name)
 local value=cmdset[name]

 if type(value) == 'function' then
  return value(cmd_seq)
 else
  return eval_cmd(input, cmd_seq, value)
 end
end

