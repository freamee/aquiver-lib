RegisterNetEvent(_G.APIServer.resource .. "peds:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.PedManager.peds) do
        v:createForPlayer(playerId)
    end
end)
