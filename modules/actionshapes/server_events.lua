RegisterNetEvent("AquiverLib:Actionshape:RequestData", function()
    local source <const> = source

    for k, v in pairs(Server.Managers.Actionshapes.Entities) do
        TriggerClientEvent("AquiverLib:Actionshape:Create", source, v.remoteId, v.data)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    for k, v in pairs(Server.Managers.Actionshapes.Entities) do
        if v.data.resource == resourceName then
            v.destroy()
        end
    end
end)