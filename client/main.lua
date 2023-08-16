local CreateThread = Citizen.CreateThread;
local Wait = Citizen.Wait;
local SetTimeout = Citizen.SetTimeout;

local GetActivePlayers = GetActivePlayers;
local GetPlayerServerId = GetPlayerServerId;
local GetPlayerPed = GetPlayerPed;
local GetEntityCoords = GetEntityCoords;
local GetPlayerServerId = GetPlayerServerId;
local GetPlayerServerId = GetPlayerServerId;

local vec3 = vec3;
local math_cos = math.cos;
local math_sin = math.sin;
local table_insert = table.insert;
local pairs = pairs;

local VoiceRefresh = false
local UserName = '';
local Config = nil;
local UsedURL = '';
local PlayerPool = {};

RegisterNetEvent('VoiceRangeChanged');

RegisterNetEvent('UpdatePlayerPool', function(Pool)
  PlayerPool = Pool
end)

RegisterNetEvent('SetupReceived', function(Data)
  Config = Data

  RegisterKeyMapping('voicerange', 'Toggle Voicerange', 'keyboard', Config.VoiceRangeMapper)

  CreateThread(function()
    while true do
      Wait(50)
      OnVoiceTick()
    end
  end)
end)

RegisterNetEvent('VoiceConnect', function(Active, Id)
  if Active then
    UserName = Config.UserPrefix .. Id
    SetTimeout(500, function()
      VoiceRefresh = true
    end)
  else
    VoiceRefresh = false
  end
end)

function OnVoiceTick()
  if VoiceRefresh then
    VoiceRefresh = false
    local Player = PlayerPedId()
    local PlayerPos = GetEntityCoords(Player)
    local PlayerHeading = GetEntityHeading(Player)
    local PlayerRotation = math.pi / 180 * (PlayerHeading * -1)
    local PlayerNames = {}

    for _, TargetPlayer in pairs(GetActivePlayers()) do
      local TargetPlayerServerId = GetPlayerServerId(TargetPlayer)
      local PoolData = PlayerPool[tostring(TargetPlayerServerId)]
      if PoolData and not PoolData.muted then
        local TargetPlayerPed = GetPlayerPed(TargetPlayer)
        local StreamedTargetPlayerPos = GetEntityCoords(TargetPlayerPed)
        local Distance = #(vec3(PlayerPos.x, PlayerPos.y, PlayerPos.z) - vec3(StreamedTargetPlayerPos.x, StreamedTargetPlayerPos.y, StreamedTargetPlayerPos.z))
        local VolumeModifier = 0
        local TargetPlayerVoiceRange = PoolData.range

        if Distance >= 5 then
          VolumeModifier = (Distance * -5 / 10)
        end

        if VolumeModifier > 0 then
          VolumeModifier = 0
        end

        if Distance <= TargetPlayerVoiceRange then
          SubPos = {
            X = StreamedTargetPlayerPos.x - PlayerPos.x,
            Y = StreamedTargetPlayerPos.y - PlayerPos.y,
          }

          local x = SubPos.X * math_cos(PlayerRotation) - SubPos.Y * math_sin(PlayerRotation)
          local y = SubPos.X * math_cos(PlayerRotation) + SubPos.Y * math_sin(PlayerRotation)
          x = x * 10 / TargetPlayerVoiceRange
          y = y * 10 / TargetPlayerVoiceRange
          table_insert(PlayerNames,
            Config.UserPrefix ..
            TargetPlayerServerId ..
            '~' ..
            (Round(x * 1000) / 1000) ..
            '~' .. (Round(y * 1000) / 1000) .. '~0~' .. (Round(VolumeModifier * 1000) / 1000))
        end
      end
    end

    local URL = 'http://localhost:15555/custom_players2/' ..
        Config.ChannelName ..
        '/' .. Config.ChannelPassword .. '/' .. UserName .. '/' .. table.concat(PlayerNames, ';')

    if UsedURL ~= URL then
      UsedURL = URL
      SendNUIMessage({
        action = 'Connect',
        URL = URL,
      })
    end

    SetTimeout(500, function()
      VoiceRefresh = true
    end)
  end
end

TriggerServerEvent('Setup')
