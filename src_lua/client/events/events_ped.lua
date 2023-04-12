RegisterNetEvent(_G.APIShared.resource .. "peds:create", function(remoteId, data)
    _G.APIClient.Managers.PedManager:createPed(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:destroy", function(remoteId)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:set:scenario", function(remoteId, scenario)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:setScenario(scenario)
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:set:animation", function(remoteId, dict, name, flag)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:setAnimation(dict, name, flag)
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.PedManager.peds) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "peds:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(_G.APIClient.Managers.PedManager.peds) do
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
