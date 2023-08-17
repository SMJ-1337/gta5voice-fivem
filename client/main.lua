-- Initiate the pool tables
local gta5voice = {
  CallPool = {},
  RadioPool = {},
  PlayerPool = {},
};

-- Citizen Natives
local CreateThread = Citizen.CreateThread;
local Wait = Citizen.Wait;

-- Game Natives
local GetPlayerPed = GetPlayerPed;
local GetEntityCoords = GetEntityCoords;
local GetPlayerServerId = GetPlayerServerId;
local GetPlayerServerId = GetPlayerServerId;
local GetPlayerServerId = GetPlayerServerId;

-- Lua Globals
local math_pi = math.pi;
local math_cos = math.cos;
local math_sin = math.sin;
local table_insert = table.insert;
local table_concat = table.concat;
local pairs = pairs;

-- Variables
local Config = nil;
local UserName = '';
local UserId = GetPlayerServerId(PlayerId());
local LastURL = '';
local BASE_URL = 'http://localhost:15555/custom_players2/';

-- Register Events
RegisterNetEvent('gta5voice:VoiceRangeChanged');
RegisterNetEvent('gta5voice:PlayerPoolChanged');
RegisterNetEvent('gta5voice:PlayerLoaded');

-- Event Functions
AddEventHandler('gta5voice:CallPoolChanged', function(Pool)
  gta5voice.CallPool = Pool;
end);

AddEventHandler('gta5voice:RadioPoolChanged', function(Pool)
  gta5voice.RadioPool = Pool;
end);

AddEventHandler('gta5voice:PlayerPoolChanged', function(Pool)
  gta5voice.PlayerPool = Pool;
end);

AddEventHandler('gta5voice:PlayerLoaded', function(Data)
  Config = Data;

  RegisterKeyMapping('toggleVoiceRange', 'Toggle Voicerange', 'keyboard', Config.VoiceRangeMapper);

  UserName = Config.UserPrefix .. UserId;
  Wait(500);

  CreateThread(function()
    while true do
      OnVoiceTick();
      Wait(550);
    end
  end);
end);

-- Functions
function gta5voice.ChangeURL(URL)
  SendNUIMessage({
    action = 'SetFrameUrl',
    url = URL,
  });
end

function OnVoiceTick()
  local Player = PlayerPedId();
  local PlayerPos = GetEntityCoords(Player);
  local PlayerHeading = GetEntityHeading(Player);
  local PlayerRotation = math_pi / 180 * (PlayerHeading * -1);
  local PlayerNames = {};
  local MyPool = gta5voice.PlayerPool[tostring(UserId)];

  for str_Target, PoolData in pairs(gta5voice.PlayerPool) do
    local TargetServerId = tonumber(str_Target) or -1;
    local Target = GetPlayerFromServerId(TargetServerId);

    if PoolData and not PoolData.muted then
      local TargetPed = GetPlayerPed(Target);
      local TargetPos = GetEntityCoords(TargetPed);
      local Distance = #(PlayerPos - TargetPos);
      local TargetVoiceRange = PoolData.range;

      if Distance <= TargetVoiceRange then
        local VolumeModifier = 0;

        if Distance >= 5 then
          VolumeModifier = (Distance * -5 / 10);
        end

        if VolumeModifier > 0 then
          VolumeModifier = 0;
        end

        SubPos = {
          X = TargetPos.x - PlayerPos.x,
          Y = TargetPos.y - PlayerPos.y,
        };

        local x = SubPos.X * math_cos(PlayerRotation) - SubPos.Y * math_sin(PlayerRotation);
        local y = SubPos.X * math_cos(PlayerRotation) + SubPos.Y * math_sin(PlayerRotation);

        x = x * 10 / TargetVoiceRange;
        y = y * 10 / TargetVoiceRange;

        local Name = PoolData.name ..
            '~' ..
            (Round(x * 1000) / 1000) .. '~' .. (Round(y * 1000) / 1000) .. '~0~' .. (Round(VolumeModifier * 1000) / 1000);

        table_insert(PlayerNames, Name);
      elseif
          (PoolData.callId and PoolData.callId == MyPool.callId) or
          (PoolData.radioId and PoolData.radioId == MyPool.radioId)
      then
        table_insert(PlayerNames, PoolData.name .. '~10~0~0~3');
      end
    end
  end

  local URL = BASE_URL ..
      Config.ChannelName .. '/' .. Config.ChannelPassword .. '/' .. UserName .. '/' .. table_concat(PlayerNames, ';');

  if LastURL ~= URL then
    LastURL = URL;

    gta5voice.ChangeURL(URL);
  end
end

-- Export Data
exports('getVoiceObject', function()
  return gta5voice;
end);

-- Initiate the client
TriggerServerEvent('gta5voice:PlayerConnected');
