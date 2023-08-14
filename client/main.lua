local Ready = false
local VoiceRefresh = false
local UserName = ""
local Configdata
local UsedURL = ""
local PlayerPool = {}

RegisterNetEvent('UpdatePlayerPool', function(PlayerPool)
    PlayerPool = PlayerPool
end)

RegisterNetEvent('SetupReceived', function(Data)
    Configdata = Data
end)

RegisterNetEvent('VoiceConnect', function(Active, Id)
    if Active then
        UserName = Configdata.UserPrefix .. Id
        Citizen.SetTimeout(500, function()
            VoiceRefresh = Active
        end)
    else
        VoiceRefresh = Active
    end
end)

RegisterKeyMapping('voicerange', 'Toggle Voicerange', 'keyboard', Configdata.VoiceRangeMapper)

function Voice()
    if VoiceRefresh then
        VoiceRefresh = false
        Player = PlayerPedId()
        PlayerPos = GetEntityCoords(Player)
        PlayerHeading = GetEntityHeading(Player)
        PlayerRotation = math.pi / 180 * (PlayerHeading * -1)
        PlayerNames = {}

        for _, TargetPlayer in ipairs(GetActivePlayers()) do
            TargetPlayerPed = GetPlayerPed(TargetPlayer)
            TargetPlayerServerId = GetPlayerServerId(TargetPlayer)
            StreamedTargetPlayerPos = GetEntityCoords(TargetPlayerPed)
            Distance = #(vec3(PlayerPos.x, PlayerPos.y, PlayerPos.z) - vec3(StreamedTargetPlayerPos.x, StreamedTargetPlayerPos.y, StreamedTargetPlayerPos.z))
            VolumeModifier = 0
            TargetPlayerVoiceRange = PlayerPool[TargetPlayerServerId].range

            if Distance > 5 then
                VolumeModifier = (Distance * -5 / 10)
            end

            if VolumeModifier > 0 then
                VolumeModifier = 0
            end

            if Distance < TargetPlayerVoiceRange then
                SubPos = {
                    X = StreamedTargetPlayerPos.x - PlayerPos.x,
                    Y = StreamedTargetPlayerPos.y - PlayerPos.y,
                }

                x = SubPos.X * math.cos(PlayerRotation) - SubPos.Y * math.sin(PlayerRotation)
                y = SubPos.X * math.cos(PlayerRotation) + SubPos.Y * math.sin(PlayerRotation)
                x = x * 10 / TargetPlayerVoiceRange
                y = y * 10 / TargetPlayerVoiceRange
                table.insert(PlayerNames, Configdata.UserPrefix .. TargetPlayerServerId .. "~" .. (Round(x * 1000) / 1000) .. "~" .. (Round(y * 1000) / 1000) .. "~0~" .. (Round(VolumeModifier * 1000) / 1000))
            end
        end

        URL = "http://localhost:15555/custom_players2/" ..
        Configdata.ChannelName ..
        "/" .. Configdata.ChannelPassword .. "/" .. UserName .. "/" .. table.concat(PlayerNames, ";") .. "/"

        if UsedURL ~= URL then
            UsedURL = URL
            SendNUIMessage({
                action = "Connect",
                URL = URL,
            })            
        end

        Citizen.SetTimeout(500, function()
            VoiceRefresh = true
        end)
    end
end

Citizen.CreateThread(function()
    Ready = true
    TriggerServerEvent('Setup')

    while Ready do
        Citizen.Wait(50)
        Voice()
    end
end)