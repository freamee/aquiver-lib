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

AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.ActionshapeManager.shapes) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "actionshapes:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

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
