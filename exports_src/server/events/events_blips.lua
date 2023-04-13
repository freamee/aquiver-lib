RegisterNetEvent(_G.APIShared.resource .. "blips:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.BlipManager.blips) do
        v:createForPlayer(playerId)
    end
end)
