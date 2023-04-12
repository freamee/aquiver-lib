---@class API_Server_PlayerBase
---@field playerId number
---@field private variables table<string, any>
local Player = {}
Player.__index = Player

Player.new = function(playerId)
    local self = setmetatable({}, Player)

    self.variables = {}
    self.playerId = playerId

    self:__init__()

    return self
end

---@private
function Player:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new player (%d)", self.playerId)
    )

    TriggerEvent(_G.APIShared.resource .. ":onPlayerCreated", self)
end

function Player:getPed()
    return GetPlayerPed(self.playerId)
end

---@param key string
---@param value any
function Player:setVar(key, value)
    if self.variables[key] == value then return end

    self.variables[key] = value

    TriggerClientEvent(_G.APIShared.resource .. ":onPlayerVariableChange", self.playerId, key, value)
    TriggerEvent(_G.APIShared.resource .. ":onPlayerVariableChange", self, key, value)
end

---@param key string
function Player:getVar(key)
    return self.variables[key]
end

---@param x number
---@param y number
---@param z number
function Player:setPosition(x, y, z)
    SetEntityCoords(self:getPed(), x, y, z, false, false, false, false)
end

---@return string | nil
function Player:getIdentifier()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getIdentifier()
    else
        for _, v in pairs(GetPlayerIdentifiers(self.playerId)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                return v
            end
        end
    end
end

function Player:getGroup()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getGroup()
    else
        return "admin"
    end
end

function Player:getJobName()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getJob().name --[[@as string]]
    else
        return "police"
    end
end

function Player:getJobGrade()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getJob().grade --[[@as number]]
    else
        return 0
    end
end

function Player:getName()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getName()
    else
        return GetPlayerName(self.playerId)
    end
end

function Player:setMoney(money)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        xPlayer.setMoney(money)
    else

    end
end

function Player:getMoney()
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getMoney()
    else
        return 0
    end
end

---@param amount number
function Player:addMoney(amount)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        xPlayer.addMoney(amount)
    else

    end
end

---@param amount number
function Player:removeMoney(amount)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        xPlayer.removeMoney(amount)
    else

    end
end

---@param accountName string
function Player:getAccount(accountName)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        return xPlayer.getAccount(accountName)
    else

    end
end

---@param accountName string
---@param amount number
function Player:addAccountMoney(accountName, amount)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        xPlayer.addAccountMoney(accountName, amount)
    else

    end
end

---@param accountName string
---@param amount number
function Player:removeAccountMoney(accountName, amount)
    if _G.APIServer.ESX then
        local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
        if not xPlayer then return end
        xPlayer.removeAccountMoney(accountName, amount)
    else

    end
end

return Player
