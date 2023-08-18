local IsDrawingRangeCircle = false
AddEventHandler('gta5voice:VoiceRangeChanged', function(range, index)
  IsDrawingRangeCircle = false;
  Wait(0);
  local Reset = true;

  IsDrawingRangeCircle = true;
  CreateThread(function()
    local DrawMarker = DrawMarker;
    local range = range * 2.0;
    local _vec = vec3(0.0, 0.0, 1.0);
    while IsDrawingRangeCircle do
      local coords = GetEntityCoords(PlayerPedId());
      ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
      DrawMarker(1, coords - _vec, 0, 0, 0, 0, 0, 0, range, range, 0.8, 160, 61, 198, 255)
      if IsDrawingRangeCircle == false then
        Reset = false;
        break;
      end
      Wait(0);
    end
  end);
  Wait(1500);
  if Reset then
    IsDrawingRangeCircle = false;
  end
end);
