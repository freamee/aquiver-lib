RegisterNetEvent("AquiverLib:Blip:RequestData", function()
    local source <const> = source

    for k, v in pairs(Server.Managers.Blips.Entities) do
        TriggerClientEvent("AquiverLib:Blip:Create", source, v.remoteId, v.data)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    for k, v in pairs(Server.Managers.Blips.Entities) do
        if v.data.resource == resourceName then
            v.destroy()
        end
    end
end)