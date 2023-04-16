-- menuExecuteCallback
RegisterNetEvent("menuExecuteCallback", function(index)
    local playerId = source
    local player = _G.APIServer.Managers.PlayerManager:getPlayer(playerId)
    if not player then return end

    if player.currentMenuData and player.currentMenuData.menus[index] and type(player.currentMenuData.menus[index].callback) == "function" then
        player.currentMenuData.menus[index].callback()
    end
end)
