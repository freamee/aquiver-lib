RegisterNetEvent("AquiverLib:Blip:Create", function(remoteId, data)
    Client.Classes.Blips(remoteId, data)
end)
RegisterNetEvent("AquiverLib:Blip:Destroy", function(remoteId)
    local aBlip = Client.Managers.Blips:atRemoteId(remoteId)
    if not aBlip then return end
    aBlip.destroy()
end)
RegisterNetEvent("AquiverLib:Blip:Update:Color", function(remoteId, colorId)
    local aBlip = Client.Managers.Blips:atRemoteId(remoteId)
    if not aBlip then return end

    aBlip.data.color = colorId

    if DoesBlipExist(aBlip.blipHandle) then
        SetBlipColour(aBlip.blipHandle, colorId)
    end
end)
RegisterNetEvent("AquiverLib:Blip:Update:Position", function(remoteId, x, y, z)
    local aBlip = Client.Managers.Blips:atRemoteId(remoteId)
    if not aBlip then return end

    aBlip.data.x = x
    aBlip.data.y = y
    aBlip.data.z = z

    if DoesBlipExist(aBlip.blipHandle) then
        SetBlipCoords(aBlip.blipHandle, x, y, z)
    end
end)

-- Requesting objects from server on client load.
Citizen.CreateThread(function()
    while true do

        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent("AquiverLib:Blip:RequestData")
            break
        end

        Citizen.Wait(500)
    end
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    for k, v in pairs(Client.Managers.Blips.Entities) do
        if v.data.resource == resourceName then
            v.destroy()
        end
    end
end)