PlayerPool = {}

RegisterNetEvent('Setup', function()
    TriggerClientEvent('SetupReceived', source, Config)
    PlayerPool[source] = { range = 15 }
    TriggerClientEvent('VoiceConnect', source, true, source)
    TriggerClientEvent('UpdatePlayerPool', -1, PlayerPool)
end)

RegisterCommand('VoiceRange', function(source)
    for _, range in pairs(Config.Ranges) do
        if PlayerPool[source].range == range then
            if Config.Ranges[_+1] then
                PlayerPool[source].range = Config.Ranges[_+1]
            else
                PlayerPool[source].range = Config.Ranges[1]
            end
            TriggerClientEvent('UpdatePlayerPool', -1, PlayerPool)
            break
        end
    end
end, false)