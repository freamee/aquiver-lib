RegisterNetEvent(_G.APIShared.resource .. "actionshapes:create", function(remoteId, data)
    _G.APIClient.Managers.ActionshapeManager:createActionshape(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:destroy", function(remoteId)
    local actionshape = _G.APIClient.Managers.ActionshapeManager:getActionshape(remoteId)
    if not actionshape then return end
    actionshape:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:set:position", function(remoteId, x, y, z)
    local actionshape = _G.APIClient.Managers.ActionshapeManager:getActionshape(remoteId)
    if not actionshape then return end
    actionshape:setPosition(vector3(x, y, z))
end)

_G.APIShared.EventHandler:AddEvent("ScriptStopped", function()
    for k, v in pairs(_G.APIClient.Managers.ActionshapeManager.shapes) do
        v:destroy()
    end
end)

_G.APIShared.EventHandler:AddEvent("PlayerLoaded", function()
    TriggerServerEvent(_G.APIShared.resource .. "actionshapes:request:data")
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = _G.APIClient.LocalPlayer.cache.playerCoords

        for k, v in pairs(_G.APIClient.Managers.ActionshapeManager.shapes) do
            local dist = v:dist(playerCoords)
            if dist < v.data.streamDistance then
                v:addStream()
            else
                v:removeStream()
            end

            if dist < v.data.range then
                v:onEnter()
            else
                v:onLeave()
            end
        end

        Citizen.Wait(1000)
    end
end)
