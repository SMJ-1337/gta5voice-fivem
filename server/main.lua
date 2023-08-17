-- Initiate the pool tables
local gta5voice = {
  CallPool = {},
  RadioPool = {},
  PlayerPool = {},
};

-- Game Natives
local DropPlayer = DropPlayer;

-- Lua Globals
local type = type;
local tostring = tostring;
local table_insert = table.insert;
local table_remove = table.remove;
local pairs = pairs;

-- add the player to the player pool
RegisterNetEvent('gta5voice:PlayerConnected', function()
  local source = source;

  -- if the player already exists in the pool, then kick him
  if gta5voice.PlayerPool[tostring(source)] then
    return DropPlayer(source,
      '[gta5voice] | Player triggered "gta5voice:PlayerConnected", although the player already existed');
  end

  -- create player table
  gta5voice.PlayerPool[tostring(source)] = {
    range = Config.Ranges[1],
    muted = false,
    name = Config.UserPrefix .. source,
    callId = nil,
    radioId = nil,
  };

  -- send the config to the new client
  TriggerClientEvent('gta5voice:PlayerLoaded', source, Config);
  -- update the player pool for all existing clients
  TriggerClientEvent('gta5voice:PlayerPoolChanged', -1, gta5voice.PlayerPool);
end)

-- Toggle increment voice range for specified player
local function toggleVoiceRange(player)
  local source = tostring(player);

  -- loop through all voice ranges, that have been configured
  for _, range in pairs(Config.Ranges) do
    -- check if the loop found the matching one
    if gta5voice.PlayerPool[source].range == range then
      local Index = _ + 1;
      local newRange = Config.Ranges[_ + 1];

      -- if the higher voice range doesn't exist than go back to the first
      if not Config.Ranges[_ + 1] then
        newRange = 1;
        Index = 1;
      end

      -- update the pool data for the specified player
      gta5voice.PlayerPool[source].range = newRange;

      -- let the client know that the voice range has been updated
      -- this event is simply for implementation in other scripts
      TriggerClientEvent('gta5voice:VoiceRangeChanged', player, newRange, Index);
      -- send all clients the new player pool
      TriggerClientEvent('gta5voice:PlayerPoolChanged', -1, gta5voice.PlayerPool);

      -- return the new voice range
      return newRange;
    end
  end
end
-- register a command for the function
RegisterCommand('toggleVoiceRange', toggleVoiceRange, false);
-- export the function
exports('toggleVoiceRange', toggleVoiceRange);

AddEventHandler('playerDropped', function()
  -- turn the source to a string
  local source = tostring(source);
  local Index = 0;
  local RadioId = false;
  local CallId = false;

  -- Loop through the Player Pool
  for str_Source, PoolData in pairs(gta5voice.PlayerPool) do
    -- Increment the index by 1
    Index += 1;

    -- check if the key matches the source
    if str_Source == source then
      -- check if the player was in a radio call
      if PoolData.radioId then
        -- if so set the value to the radio call id
        RadioId = PoolData.radioId;
      end

      -- check if the player was in a call
      if PoolData.callId then
        -- if so set the value to the call id
        CallId = PoolData.callId;
      end

      -- remove the player from the player pool
      table_remove(gta5voice.PlayerPool, Index);
      break;
    end
  end

  -- Check if is in radio, if is in radio then remove from table, if it exists
  if RadioId and gta5voice.RadioPool[tostring(RadioId)] then
    -- Loop trough all the player sources and look for the matching one
    for _, s in pairs(gta5voice.RadioPool[tostring(RadioId)]) do
      -- check if source is matching
      if tostring(s) == source then
        -- source matched, so it gets removed
        table_remove(gta5voice.CallPool[tostring(RadioId)], _);
        break;
      end
    end
  end

  -- Check if is in call, if is in call then remove from table, if it exists
  if CallId and gta5voice.CallPool[tostring(CallId)] then
    -- Loop trough all the player sources and look for the matching one
    for _, s in pairs(gta5voice.CallPool[tostring(CallId)]) do
      -- check if source is matching
      if tostring(s) == source then
        -- source matched, so it gets removed
        table_remove(gta5voice.RadioPool[tostring(CallId)], _);
        break;
      end
    end
  end
end);

-- Exports
-- Mute specified player for the whole server
exports('MutePlayer', function(target, bool)
  local source = tostring(target);

  gta5voice.PlayerPool[source]?.muted = bool;
end)

local function addPlayerToPool(target, id, poolData)
  -- turning the id and source to a string, to use as a table key
  local value = tostring(id);
  local source = tostring(target);

  if not gta5voice[poolData.name][value] then
    -- if the pool with the specified doesn't already exist, then initiate it
    gta5voice[poolData.name][value] = {};
  end

  -- insert the original source to the pool
  table_insert(gta5voice[poolData.name][value], target);

  -- update the player data
  gta5voice.PlayerPool[source][poolData.value] = value;

  -- update the call/radio pool for all clients
  -- this event is simply for implementation in other scripts
  TriggerClientEvent('gta5voice:' .. poolData.name .. 'Changed', -1, gta5voice[poolData.name]);
  -- update the player pool for all clients
  TriggerClientEvent('gta5voice:PlayerPoolChanged', -1, gta5voice.PlayerPool);
end

-- Add specified player to radio channel
exports('AddPlayerToRadio', function(target, id)
  -- check if the first argument is a string
  if type(target) == 'table' then
    -- if so loop through all players and add them to the specified pool
    for _, tar in pairs(target) do
      addPlayerToPool(tar, id, { name = 'RadioPool', value = 'radioId' });
    end
  else
    -- if not then only add one player
    addPlayerToPool(target, id, { name = 'RadioPool', value = 'radioId' });
  end
end);

-- Add specified player to call
exports('AddPlayerToPhone', function(target, id)
  if type(target) == 'table' then
    for _, tar in pairs(target) do
      addPlayerToPool(tar, id, { name = 'CallPool', value = 'callId' });
    end
  else
    addPlayerToPool(target, id, { name = 'CallPool', value = 'callId' });
  end
end);

-- Export Data
exports('getVoiceObject', function()
  return gta5voice;
end);
