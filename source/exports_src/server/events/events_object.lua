RegisterNetEvent(_G.APIShared.resource .. "objects:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.ObjectManager.objects) do
        v:createForPlayer(playerId)
    end
end)
