local PlayerState = Player

---@class API_Server_PlayerBase
---@field playerId number
---@field private variables table<string, any>
---@field attachments table<string, boolean>
---@field currentMenuData IMenu
local Player = {}
Player.__index = Player

Player.new = function(playerId)
    local self = setmetatable({}, Player)

    self.variables = {}
    self.attachments = {}
    self.playerId = playerId
    self.currentMenuData = nil

    self:__init__()
    self:setDimension(self:getDimension())

    return self
end

---@private
function Player:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new player (%d)", self.playerId)
    )

    _G.APIShared.EventHandler:TriggerEvent("onPlayerCreated", self)
end

function Player:getPed()
    return GetPlayerPed(self.playerId)
end

function Player:getDimension()
    return GetPlayerRoutingBucket(self.playerId)
end

---@param dimension number
function Player:setDimension(dimension)
    PlayerState(self.playerId).state:set("playerDimension", dimension, true)

    SetPlayerRoutingBucket(self.playerId, dimension)
    _G.APIShared.EventHandler:TriggerEvent("onPlayerDimensionChange", self, oldDimension, dimension)
end

---@param key string
---@param value any
function Player:setVar(key, value)
    if self.variables[key] == value then return end

    self.variables[key] = value

    TriggerClientEvent(_G.APIShared.resource .. ":onPlayerVariableChange", self.playerId, key, value)
    _G.APIShared.EventHandler:TriggerEvent("onPlayerVariableChange", self, key, value)
end

---@param key string
function Player:getVar(key)
    return self.variables[key]
end

function Player:sendApiMessage(jsonContent)
    TriggerClientEvent("aquiver-lib:sendApiMessage", self.playerId, jsonContent)
end

function Player:sendNuiMessage(jsonContent)
    TriggerClientEvent(_G.APIShared.resource .. ":sendNuiMessage", self.playerId, jsonContent)
end

---@param dict string
---@param name string
---@param flag number
---@param timeMS number
---@param cb function
function Player:playAnimationPromise(dict, name, flag, timeMS, cb)
    if self.variables.hasAnimPromise then return end

    self.variables.hasAnimPromise = true
    self:playAnimation(dict, name, flag)

    SetTimeout(timeMS, function()
        if not self then return end

        self.variables.hasAnimPromise = false
        self:stopAnimation()

        if type(cb) == "function" then
            cb()
        end
    end)
end

---@param dict string
---@param name string
---@param flag number
function Player:playAnimation(dict, name, flag)
    TriggerClientEvent(_G.APIShared.resource .. "player:playAnimation", self.playerId, dict, name, flag)
end

function Player:stopAnimation()
    TriggerClientEvent(_G.APIShared.resource .. "player:stopAnimation", self.playerId)
end

---@param state boolean
function Player:disableMovement(state)
    TriggerClientEvent(_G.APIShared.resource .. "player:disableMovement", self.playerId, state)
end

---@param state boolean
function Player:freeze(state)
    TriggerClientEvent(_G.APIShared.resource .. "player:freeze", self.playerId, state)
end

---@param helpData IHelp
function Player:addHelp(helpData)
    self:triggerClient("PLAYER_HELP_ADD_FROM_SERVER", helpData)
end

---@param uid string
function Player:removeHelp(uid)
    self:triggerClient("PLAYER_HELP_REMOVE_FROM_SERVER", uid)
end

---@param eventName string
---@param ... any
function Player:triggerClient(eventName, ...)
    TriggerClientEvent(eventName, ...)
end

function Player:addAttachment(attachmentName)
    if not _G.APIShared.AttachmentManager:exist(attachmentName) then
        _G.APIShared.Helpers.Logger:error(
            string.format("Attachment %s not registered.", attachmentName)
        )
        return
    end

    if self:hasAttachment(attachmentName) then return end

    self.attachments[attachmentName] = true

    TriggerClientEvent(_G.APIShared.resource .. "entity:player:addAttachment", -1, self.playerId, attachmentName)
end

function Player:removeAttachment(attachmentName)
    if not self:hasAttachment(attachmentName) then return end

    self.attachments[attachmentName] = nil
    TriggerClientEvent(_G.APIShared.resource .. "entity:player:removeAttachment", -1, self.playerId, attachmentName)
end

function Player:getAttachmentCount()
    local count = 0
    for k, v in pairs(self.attachments) do
        count = count + 1
    end
    return count
end

function Player:hasAttachment(attachmentName)
    return self.attachments[attachmentName] and true or false
end

---@param type "error" | "success" | "info" | "warning"
---@param message string
function Player:notification(type, message)
    self:sendApiMessage({
        event = "SEND_NOTIFICATION",
        type = type,
        message = message
    })
end

function Player:createMenuBuilder()
    local menu = {}
    menu._data = {
        header = "unknown",
        executeInResource = _G.APIShared.resource,
        menus = {}
    }
    self.currentMenuData = {
        header = "unknown",
        menus = {}
    }
    menu.setHeader = function(header)
        menu._data.header = header
        self.currentMenuData.header = header
    end
    ---@param menuEntry IMenuEntry
    menu.addMenu = function(menuEntry)
        menu._data.menus[#menu._data.menus + 1] = {
            icon = menuEntry.icon,
            name = menuEntry.name
        }
        self.currentMenuData.menus[#self.currentMenuData.menus + 1] = menuEntry
    end
    menu.open = function()
        self:sendApiMessage({
            event = "MenuOpen",
            menuData = menu._data
        })
    end

    return menu
end

--- Start progress for player.
--- Callback passes the Player after the progress is finished: cb(Player)
---@param text string
---@param time number Time in milliseconds (MS) 1000ms-1second
---@param cb fun()
function Player:progress(text, time, cb)
    if self:getVar("hasProgress") then return end

    self:setVar("hasProgress", true)

    self:sendApiMessage({
        event = "StartProgress",
        time = time,
        text = text
    })

    SetTimeout(time, function()
        if not self then return end

        self:setVar("hasProgress", false)

        if type(cb) == "function" then
            cb()
        end
    end)
end

---@param x number
---@param y number
---@param z number
function Player:setPosition(x, y, z)
    SetEntityCoords(self:getPed(), x, y, z, false, false, false, false)
end

---@param heading number
function Player:setHeading(heading)
    SetEntityHeading(self:getPed(), heading)
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
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        self:notification(
            "info",
            string.format("[DEVELOPMENT-TEST]: Player:setMoney -> %d", money)
        )
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            xPlayer.setMoney(money)
        else

        end
    end
end

function Player:getMoney()
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        return 66666
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            return xPlayer.getMoney()
        else
            return 0
        end
    end
end

---@param amount number
function Player:addMoney(amount)
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        self:notification(
            "info",
            string.format("[DEVELOPMENT-TEST]: Player:addMoney -> %d", money)
        )
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            xPlayer.addMoney(amount)
        else

        end
    end
end

---@param amount number
function Player:removeMoney(amount)
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        self:notification(
            "info",
            string.format("[DEVELOPMENT-TEST]: Player:removeMoney -> %d", money)
        )
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            xPlayer.removeMoney(amount)
        else

        end
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
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        self:notification(
            "info",
            string.format("[DEVELOPMENT-TEST]: Player:addAccountMoney -> %s  %d", accountName, money)
        )
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            xPlayer.addAccountMoney(accountName, amount)
        else

        end
    end
end

---@param accountName string
---@param amount number
function Player:removeAccountMoney(accountName, amount)
    if _G.APIShared.CONFIG.AQUIVER_TEST_SERVER then
        self:notification(
            "info",
            string.format("[DEVELOPMENT-TEST]: Player:removeAccountMoney -> %s  %d", accountName, money)
        )
    else
        if _G.APIServer.ESX then
            local xPlayer = _G.APIServer.ESX.GetPlayerFromId(self.playerId)
            if not xPlayer then return end
            xPlayer.removeAccountMoney(accountName, amount)
        else

        end
    end
end

return Player
