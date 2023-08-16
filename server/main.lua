PlayerPool = {}

RegisterNetEvent('gta5voice:PlayerConnected', function()
  local source = source;
  if PlayerPool[tostring(source)] then
    return DropPlayer(source, 'Exploit');
  end

  PlayerPool[tostring(source)] = {
    range = 15,
    muted = false,
    name = Config.UserPrefix .. source
  };

  TriggerClientEvent('gta5voice:PlayerLoaded', source, Config);
  TriggerClientEvent('gta5voice:PlayerPoolChanged', -1, PlayerPool);
end)

exports('MutePlayer', function(target, bool)
  local source = tostring(target);
  if PlayerPool[source] then
    PlayerPool[source].muted = bool;
  end
end)

RegisterCommand('voicerange', function(source)
  for _, range in pairs(Config.Ranges) do
    if PlayerPool[tostring(source)].range == range then
      local Index = _ + 1;

      if Config.Ranges[_ + 1] then
        PlayerPool[tostring(source)].range = Config.Ranges[_ + 1];
      else
        PlayerPool[tostring(source)].range = Config.Ranges[1];
        Index = 1;
      end

      TriggerClientEvent('gta5voice:VoiceRangeChanged', source, Config.Ranges[Index], Index);
      TriggerClientEvent('gta5voice:PlayerPoolChanged', -1, PlayerPool);
      break;
    end
  end
end, false);

AddEventHandler('playerDropped', function()
  local source = tostring(source);
  local Index = 0;

  for str_Source, _ in pairs(PlayerPool) do
    Index += 1;

    if str_Source == source then
      table.remove(PlayerPool, Index);
      break;
    end
  end
end);