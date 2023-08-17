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
local GetPlayerFromServerId = GetPlayerFromServerId;

-- Lua Globals
local tonumber = tonumber;
local math_pi = math.pi;
local math_cos = math.cos;
local math_sin = math.sin;
local math_floor = math.floor;
local function math_round(value)
  return math_floor(value + 0.5);
end
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

  -- add key assignment for the voice range command
  RegisterKeyMapping('toggleVoiceRange', 'Toggle Voicerange', 'keyboard', Config.VoiceRangeMapper);

  -- set the clients user name
  UserName = Config.UserPrefix .. UserId;

  -- initiate the main thread
  CreateThread(function()
    while true do
      -- trigger main voice function
      OnVoiceTick();
      -- tick all 200ms
      Wait(200);
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
  -- define player position, ped, etc
  -- used to compare distance, etc
  local Player = PlayerPedId();
  local PlayerPos = GetEntityCoords(Player);
  local PlayerHeading = GetEntityHeading(Player);
  local PlayerRotation = math_pi / 180 * (PlayerHeading * -1);
  -- init the PlayerNames table, were all voice clients get stored
  local PlayerNames = {};
  -- define current client pool data as MyPool
  local MyPool = gta5voice.PlayerPool[tostring(UserId)];

  -- Loop through the PlayerPool
  for str_Target, PoolData in pairs(gta5voice.PlayerPool) do
    -- check if the current player is the current client
    if str_Target ~= tostring(UserId) then
      -- define the client and server id for the current player
      local TargetServerId = tonumber(str_Target) or -1;
      local Target = GetPlayerFromServerId(TargetServerId);

      -- if the data exists and the player isn't muted then proceed
      if PoolData and not PoolData.muted then
        local TargetPed = GetPlayerPed(Target);

        -- check if the player is in my range/stream (what ever) and if he has a ped
        if NetworkIsPlayerActive(Target) and DoesEntityExist(TargetPed) then
          -- define player pos, distance and voice range
          local TargetPos = GetEntityCoords(TargetPed);
          local Distance = #(PlayerPos - TargetPos);
          local TargetVoiceRange = PoolData.range;

          -- check if the player is hearable for the current client,
          -- by comparing my distance to him with his voice range
          if Distance <= TargetVoiceRange then
            local VolumeModifier = 0;

            -- if the distance is greater or equals 5 then modify the volume to be quieter
            if Distance >= 5 then
              VolumeModifier = (Distance * -5 / 10);
            end

            -- if the volume somehow exceeds 0, reset it to 0
            if VolumeModifier > 0 then
              VolumeModifier = 0;
            end

            -- define a table including the distance on x and y from the current client to the current player
            local SubPos = {
              X = TargetPos.x - PlayerPos.x,
              Y = TargetPos.y - PlayerPos.y,
            };

            -- do some math sh*t to define where the audio is coming from, etc
            local x = SubPos.X * math_cos(PlayerRotation) - SubPos.Y * math_sin(PlayerRotation);
            local y = SubPos.X * math_cos(PlayerRotation) + SubPos.Y * math_sin(PlayerRotation);

            x = x * 10 / TargetVoiceRange;
            y = y * 10 / TargetVoiceRange;

            -- define the player "Name", for the url to use as a parameter
            local Name = PoolData.name ..
                '~' ..
                (math_round(x * 1000) / 1000) ..
                '~' .. (math_round(y * 1000) / 1000) .. '~0~' .. (math_round(VolumeModifier * 1000) / 1000);

            -- insert it to the PlayerNames table, which we created before
            table_insert(PlayerNames, Name);
          else
            -- if the player isn't anywhere near us, or we aren't able to hear him,
            -- because our distance exceeds his voice range,
            -- then check if the client and the player are connected in a call and in the same call
            if
                (PoolData.callId and PoolData.callId == MyPool.callId) or
                (PoolData.radioId and PoolData.radioId == MyPool.radioId)
            then
              -- if so then insert him to the PlayerNames table
              table_insert(PlayerNames, PoolData.name .. '~10~0~0~3');
            end
          end
        end
      end
    end
  end

  -- define the "new iFrame url"
  local URL = BASE_URL ..
      Config.ChannelName .. '/' .. Config.ChannelPassword .. '/' .. UserName .. '/' .. table_concat(PlayerNames, ';');

  -- if the "new iFrame url" doesnt match the old one, then change it
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
