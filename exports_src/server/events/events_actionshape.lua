RegisterNetEvent(_G.APIShared.resource .. "actionshapes:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.ActionshapeManager.shapes) do
        v:createForPlayer(playerId)
    end
end)
