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

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.BlipManager.blips) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "blips:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)
