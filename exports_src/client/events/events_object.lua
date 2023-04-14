RegisterNetEvent(_G.APIShared.resource .. "objects:create", function(remoteId, data)
    _G.APIClient.Managers.ObjectManager:createObject(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:destroy", function(remoteId)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:position", function(remoteId, x, y, z)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setPosition(vector3(x, y, z))
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:rotation", function(remoteId, rx, ry, rz)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setRotation(vector3(rx, ry, rz))
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:model", function(remoteId, model)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setModel(model)
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:variablekey", function(remoteId, key, value)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setVar(key, value)
end)

_G.APIShared.EventHandler:AddEvent("ScriptStopped", function()
    for k, v in pairs(_G.APIClient.Managers.ObjectManager.objects) do
        v:destroy()
    end
end)

_G.APIShared.EventHandler:AddEvent("PlayerLoaded", function()
    TriggerServerEvent(_G.APIShared.resource .. "objects:request:data")
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = _G.APIClient.LocalPlayer.cache.playerCoords

        for k, v in pairs(_G.APIClient.Managers.ObjectManager.objects) do
            local dist = v:dist(playerCoords)
            if dist < 20.0 then
                v:addStream()
            else
                v:removeStream()
            end
        end

        Citizen.Wait(1000)
    end
end)
