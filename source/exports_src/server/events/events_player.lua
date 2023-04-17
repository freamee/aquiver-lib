RegisterNetEvent(_G.APIShared.resource .. "menuExecuteCallback", function(index)
    local playerId = source
    local player = _G.APIServer.Managers.PlayerManager:getPlayer(playerId)
    if not player then return end

    if player.currentMenuData and player.currentMenuData.menus[index] and type(player.currentMenuData.menus[index].callback) == "function" then
        player.currentMenuData.menus[index].callback()
    end
end)
RegisterNetEvent(_G.APIShared.resource .. "player:attachments:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.PlayerManager.players) do
        local attCount = v:getAttachmentCount()
        if attCount > 0 then
            TriggerClientEvent(_G.APIShared.resource .. "player:attachments:load", playerId, v.playerId, v.attachments)
        end
    end
end)
