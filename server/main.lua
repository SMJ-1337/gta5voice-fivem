PlayerPool = {}

RegisterNetEvent('Setup', function()
  local source = source
  if PlayerPool[tostring(source)] then
    DropPlayer(source, 'Exploit')
  else
    TriggerClientEvent('SetupReceived', source, Config)
    Citizen.SetTimeout(1000, function()
      PlayerPool[tostring(source)] = { range = 15, muted = false }
      TriggerClientEvent('VoiceConnect', source, true, source)
      TriggerClientEvent('UpdatePlayerPool', -1, PlayerPool)
    end)
  end
end)

exports('MutePlayer', function(source, bool)
  PlayerPool[tostring(source)].muted = bool;
end)

RegisterCommand('voicerange', function(source)
  for _, range in pairs(Config.Ranges) do
    if PlayerPool[tostring(source)].range == range then
      local Index = _ + 1
      if Config.Ranges[_ + 1] then
        PlayerPool[tostring(source)].range = Config.Ranges[_ + 1]
      else
        PlayerPool[tostring(source)].range = Config.Ranges[1]
        Index = 1
      end
      TriggerClientEvent('UpdatePlayerPool', -1, PlayerPool)
      TriggerClientEvent('VoiceRangeChanged', source, Config.Ranges[Index], Index)
      break
    end
  end
end, false)
