local convar = GetConvar('gta5voice_debug', 'no');

if convar == '\'yes\'' or convar == 'yes' then
  RegisterCommand('debug', function(s, args)
    local index = GetTableIndexBySource(s);
    local action = args[1];
    local value = args[2];
    local value2 = args[3];

    if action == 'radio' then
      if value == 'join' then
        exports.gta5voice:AddPlayerToRadio(s, value2);
      else
        exports.gta5voice:RemovePlayerToRadio(s, value2);
      end
    elseif action == 'call' then
      if value == 'join' then
        exports.gta5voice:AddPlayerToCall(s, value2);
      else
        exports.gta5voice:RemovePlayerToCall(s, value2);
      end
    end

  end, false);
end