RegisterNetEvent(_G.APIShared.resource .. "blips:create", function(remoteId, data)
    _G.APIClient.Managers.BlipManager:createBlip(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:destroy", function(remoteId)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:set:position", function(remoteId, x, y, z)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:setPosition(x, y, z)
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:set:color", function(remoteId, colorId)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:setColor(colorId)
end)

_G.APIShared.EventHandler:AddEvent("ScriptStopped", function()
    for k, v in pairs(_G.APIClient.Managers.BlipManager.blips) do
        v:destroy()
    end
end)

_G.APIShared.EventHandler:AddEvent("PlayerLoaded", function()
    TriggerServerEvent(_G.APIShared.resource .. "blips:request:data")
end)
