function GetTableIndexBySource(source, returnData)
  for _, PoolData in pairs(gta5voice.PlayerPool) do
    if PoolData.source == source then
      if returnData then
        return _, PoolData;
      else
        return _;
      end
    end
  end

  return false;
end