local Player = require("server.gameobjects.player.player")

---@class API_Server_PlayerManager
---@field players table<number, API_Server_PlayerBase>
local PlayerManager = {}
PlayerManager.__index = PlayerManager

PlayerManager.new = function()
    local self = setmetatable({}, PlayerManager)

    self.players = {}

    return self
end

function PlayerManager:getPlayer(playerId)
    return self.players[playerId]
end

function PlayerManager:onPlayerConnect(playerId)
    if self.players[playerId] then
        return self.players[playerId]
    end

    self.players[playerId] = Player.new(playerId)

    return self.players[playerId]
end

function PlayerManager:onPlayerQuit(playerId)
    if not self.players[playerId] then return end

    self.players[playerId] = nil
end

function PlayerManager:onResourceStart()
    Citizen.Wait(2000)

    local players = GetPlayers()
    for _, v in pairs(players) do
        self:onPlayerConnect(tonumber(v))
    end
end

return PlayerManager
