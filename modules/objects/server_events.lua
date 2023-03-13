RegisterNetEvent("AquiverLib:Object:RequestData", function()
    local source <const> = source

    for k, v in pairs(Server.Managers.Objects.Entities) do
        TriggerClientEvent("AquiverLib:Object:Create", source, v.remoteId, v.data)
    end
end)