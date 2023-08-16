local gta5voice = {};

-- Citizen Functions
local CreateThread = Citizen.CreateThread;
local Wait = Citizen.Wait;

-- GTA5 Natives
local GetActivePlayers = GetActivePlayers;
local GetPlayerServerId = GetPlayerServerId;
local GetPlayerPed = GetPlayerPed;
local GetEntityCoords = GetEntityCoords;
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
local PlayerPool = {};
local CallPool = {};
local RadioPool = {};
local BASE_URL = 'http://localhost:15555/custom_players2/';

-- Register Events
RegisterNetEvent('gta5voice:VoiceRangeChanged');
RegisterNetEvent('gta5voice:PlayerPoolChanged');
RegisterNetEvent('gta5voice:PlayerLoaded');

-- Event Functions
AddEventHandler('gta5voice:PlayerPoolChanged', function(Pool)
  PlayerPool = Pool
end);

AddEventHandler('gta5voice:PlayerLoaded', function(Data)
  Config = Data;

  RegisterKeyMapping('voicerange', 'Toggle Voicerange', 'keyboard', Config.VoiceRangeMapper);

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

  for _, Target in pairs(GetActivePlayers()) do
    local TargetServerId = GetPlayerServerId(Target);
    local PoolData = PlayerPool[tostring(TargetServerId)];

    if PoolData and not PoolData.muted then
      local TargetPed = GetPlayerPed(Target);
      local TargetPos = GetEntityCoords(TargetPed);
      local Distance = #(PlayerPos - TargetPos);
      local VolumeModifier = 0;
      local TargetVoiceRange = PoolData.range;

      if Distance >= 5 then
        VolumeModifier = (Distance * -5 / 10)
      end

      if VolumeModifier > 0 then
        VolumeModifier = 0
      end

      if Distance <= TargetVoiceRange then
        SubPos = {
          X = TargetPos.x - PlayerPos.x,
          Y = TargetPos.y - PlayerPos.y,
        }

        local x = SubPos.X * math_cos(PlayerRotation) - SubPos.Y * math_sin(PlayerRotation);
        local y = SubPos.X * math_cos(PlayerRotation) + SubPos.Y * math_sin(PlayerRotation);

        x = x * 10 / TargetVoiceRange;
        y = y * 10 / TargetVoiceRange;

        local Name = PoolData.name .. '~' .. (Round(x * 1000) / 1000) .. '~' .. (Round(y * 1000) / 1000) .. '~0~' .. (Round(VolumeModifier * 1000) / 1000);

        table_insert(PlayerNames, Name);
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

-- Init
TriggerServerEvent('gta5voice:PlayerConnected');
