RegisterNetEvent("AquiverLib:Ped:RequestData", function()
    local source <const> = source

    for k, v in pairs(Server.Managers.Peds.Entities) do
        TriggerClientEvent("AquiverLib:Ped:Create", source, v.remoteId, v.data)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    for k, v in pairs(Server.Managers.Peds.Entities) do
        if v.data.resource == resourceName then
            v.destroy()
        end
    end
end)