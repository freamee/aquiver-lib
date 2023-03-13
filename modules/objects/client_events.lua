RegisterNetEvent("AquiverLib:Object:Create", function(remoteId, data)
    Client.Classes.Objects(remoteId, data)
end)
RegisterNetEvent("AquiverLib:Object:Destroy", function(remoteId)
    local aObject = Client.Managers.Objects:atRemoteId(remoteId)
    if not aObject then return end
    aObject.destroy()    
end)
RegisterNetEvent("AquiverLib:Object:Update:Position", function(remoteId, x, y, z)
    local aObject = Client.Managers.Objects:atRemoteId(remoteId)
    if not aObject then return end

    aObject.data.x = x
    aObject.data.y = y
    aObject.data.z = z

    if DoesEntityExist(aObject.objectHandle) then
        SetEntityCoords(aObject.objectHandle, aObject.getVector3Position(), false, false, false, false)
    end
end)
RegisterNetEvent("AquiverLib:Object:Update:Rotation", function(remoteId, rx, ry, rz)
    local aObject = Client.Managers.Objects:atRemoteId(remoteId)
    if not aObject then return end

    aObject.data.rx = rx
    aObject.data.ry = ry
    aObject.data.rz = rz

    if DoesEntityExist(aObject.objectHandle) then
        SetEntityRotation(aObject.objectHandle, aObject.getVector3Rotation(), 2, false)
    end
end)
RegisterNetEvent("AquiverLib:Object:Update:Model", function(remoteId, newModel)
    local aObject = Client.Managers.Objects:atRemoteId(remoteId)
    if not aObject then return end

    aObject.data.model = newModel

    aObject.removeStream()
    aObject.addStream()
end)
RegisterNetEvent("AquiverLib:Object:Update:VariableKey", function(remoteId, key, value)
    local aObject = Client.Managers.Objects:atRemoteId(remoteId)
    if not aObject then return end

    aObject.data.variables[key] = value
end)

-- Requesting objects from server on client load.
Citizen.CreateThread(function()
    while true do

        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent("AquiverLib:Object:RequestData")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do

        for k, v in pairs(Client.Managers.Objects.Entities) do
            local dist = v.dist(Client.LocalPlayer.cache.playerCoords)
            if dist < 15.0 then
                v.addStream()
            else
                v.removeStream()
            end
        end

        Citizen.Wait(5000)
    end
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for k, v in pairs(Client.Managers.Objects.Entities) do
        v.destroy()
    end
end)