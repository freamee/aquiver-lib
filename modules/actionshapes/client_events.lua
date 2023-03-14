RegisterNetEvent("AquiverLib:Actionshape:Create", function(remoteId, data)
    Client.Classes.Actionshape(remoteId, data)
end)
RegisterNetEvent("AquiverLib:Actionshape:Destroy", function(remoteId)
    local aEntity = Client.Managers.Actionshapes:atRemoteId(remoteId)
    if not aEntity then return end
    aEntity.destroy()
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do

        for k, v in pairs(Client.Managers.Actionshapes.Entities) do
            local dist = v.dist(Client.LocalPlayer.cache.playerCoords)
            if dist < 10.0 then
                v.addStream()

                if dist <= v.data.range then
                    v.onEnter()
                else
                    v.onLeave()
                end
            else
                v.removeStream()
            end
        end

        Citizen.Wait(1000)
    end
end)

-- Drawing
CreateThread(function()
    while true do
        Citizen.Wait(1000)

        while #Client.Managers.Actionshapes.Streamed > 0 do
            Citizen.Wait(1)
            
            for k, value in pairs(Client.Managers.Actionshapes.Streamed) do
                DrawMarker(
                    value.data.sprite,
                    value.data.x, value.data.y, value.data.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0,
                    value.data.color.r, value.data.color.g, value.data.color.b, value.data.color.a,
                    false, false, 2, false, nil, nil, false
                )
            end
        end
    end
end)

-- Requesting objects from server on client load.
Citizen.CreateThread(function()
    while true do

        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent("AquiverLib:Actionshape:RequestData")
            break
        end

        Citizen.Wait(500)
    end
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    for k, v in pairs(Client.Managers.Actionshapes.Entities) do
        if v.data.resource == resourceName then
            v.destroy()
        end
    end
end)