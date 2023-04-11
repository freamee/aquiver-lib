-- Bundled by luabundle {"version":"1.6.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local Shared = require("shared.shared")

local Config = require("server.config")
local Managers = require("server.managers.managers")
local Helpers = require("server.helpers.helpers")

_G.APIShared = Shared

_G.APIServer = {}
_G.APIServer.Helpers = Helpers
_G.APIServer.Managers = Managers
_G.APIServer.resource = GetCurrentResourceName() --[[@as string]]
_G.APIServer.CONFIG = Config

if GetResourceState("es_extended") ~= "missing" then
    _G.APIShared.Helpers.Logger:info("ESX Framework recognized.")
    _G.APIServer.ESX = exports['es_extended']:getSharedObject()
else
    _G.APIShared.Helpers.Logger:info("Standalone framework recognized.")
end

if _G.APIServer.ESX then
    RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer, isNew)
        _G.APIServer.Managers.PlayerManager:onPlayerConnect(playerId)
    end)
else
    AddEventHandler("playerJoining", function()
        local playerId = source
        _G.APIServer.Managers.PlayerManager:onPlayerConnect(playerId)
    end)
end

AddEventHandler("playerDropped", function()
    local playerId = source
    _G.APIServer.Managers.PlayerManager:onPlayerQuit(playerId)
end)
AddEventHandler("onResourceStart", function(resourceName)
    if _G.APIServer.resource ~= resourceName then return end
    _G.APIServer.Managers.PlayerManager:onResourceStart()
end)

end)
__bundle_register("server.helpers.helpers", function(require, _LOADED, __bundle_register, __bundle_modules)
local Helpers = {}

--- Calculate and return new position after offsets are applied with heading
---@param vec3 { x:number; y:number; z:number }
---@param heading number
---@param oX number
---@param oY number
---@param oZ number
function Helpers:getOffsetFromVector3(vec3, heading, oX, oY, oZ)
    local newPos = {
        x = vec3.x,
        y = vec3.y,
        z = vec3.z
    }
    local angle = (heading * math.pi) / 180

    newPos.x = oX * math.cos(angle) - oY * math.sin(angle)
    newPos.y = oX * math.sin(angle) + oY * math.cos(angle)

    return vec3 + vector3(newPos.x, newPos.y, oZ or 0)
end

return Helpers

end)
__bundle_register("server.managers.managers", function(require, _LOADED, __bundle_register, __bundle_modules)
local PlayerManager = require("server.managers.player_manager")
local ObjectManager = require("server.managers.object_manager")
local BlipManager = require("server.managers.blip_manager")

local Managers = {
    PlayerManager = PlayerManager.new(),
    ObjectManager = ObjectManager.new(),
    BlipManager = BlipManager.new()
}

return Managers

end)
__bundle_register("server.managers.blip_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Blip = require("server.gameobjects.blip.blip")

---@class BlipManager
---@field blips table<number, API_Server_BlipBase>
---@field remoteIdCounter number
local BlipManager = {}
BlipManager.__index = BlipManager

BlipManager.new = function()
    local self = setmetatable({}, BlipManager)

    self.blips = {}
    self.remoteIdCounter = 1

    return self
end

---@param data IBlip
function BlipManager:createBlip(data)
    local remoteId = self:getNextRemoteId()

    self.blips[remoteId] = Blip.new(remoteId, data)

    return self.blips[remoteId]
end

function BlipManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function BlipManager:getBlip(remoteId)
    return self.blips[remoteId]
end

return BlipManager

end)
__bundle_register("server.gameobjects.blip.blip", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class IBlip
---@field pos vector3
---@field alpha number
---@field color number
---@field sprite number
---@field name string
---@field display? number
---@field shortRange? boolean
---@field scale? number
---@field resource? string

---@class API_Server_BlipBase
---@field data IBlip
---@field remoteId number
local Blip = {}
Blip.__index = Blip

---@param remoteId number
---@param data IBlip
Blip.new = function(remoteId, data)
    local self = setmetatable({}, Blip)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

---@private
function Blip:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new blip (%d)", self.remoteId)
    )

    self.data.display = type(self.data.display) == "number" and self.data.display or 4
    self.data.shortRange = type(self.data.shortRange) == "boolean" and self.data.shortRange or true
    self.data.scale = type(self.data.scale) == "number" and self.data.scale or 1.0
    self.data.alpha = type(self.data.alpha) == "number" and self.data.alpha or 255

    TriggerEvent(_G.APIServer.resource .. ":onBlipCreated", self)

    --     TriggerClientEvent("AquiverLib:Object:Create", -1, self.remoteId, self.data)
end

---@param colorId number
function Blip:setColor(colorId)
    self.data.color = colorId
    --     TriggerClientEvent("AquiverLib:Blip:Update:Color", -1, self.remoteId, colorId)
end

---@param vec3 vector3
function Blip:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos = vec3
    --     TriggerClientEvent("AquiverLib:Blip:Update:Position", -1, self.remoteId, x, y, z)
end

function Blip:destroy()
    if _G.APIServer.Managers.BlipManager.blips[self.remoteId] then
        _G.APIServer.Managers.BlipManager.blips[self.remoteId] = nil
    end

    TriggerEvent(_G.APIServer.resource .. "onBlipDestroyed", self)
    -- --         TriggerClientEvent("AquiverLib:Object:Destroy", self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed blip (%d)", self.remoteId)
    )
end

return Blip

end)
__bundle_register("server.managers.object_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Object = require("server.gameobjects.object.object")

---@class ObjectManager
---@field objects table<number, API_Server_ObjectBase>
---@field remoteIdCounter number
local ObjectManager = {}
ObjectManager.__index = ObjectManager

ObjectManager.new = function()
    local self = setmetatable({}, ObjectManager)

    self.objects = {}
    self.remoteIdCounter = 1

    return self
end

---@param data ISQLObject
function ObjectManager:createObject(data)
    local remoteId = self:getNextRemoteId()

    self.objects[remoteId] = Object.new(remoteId, data)

    return self.objects[remoteId]
end

function ObjectManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function ObjectManager:getObject(remoteId)
    return self.objects[remoteId]
end

---@param data ISQLObject
---@async
function ObjectManager:insertSQL(data)
    local insertId = exports["oxmysql"]:insert_async(
        "INSERT INTO avp_lib_objects (model, x, y, z, rx, ry, rz, dimension, resource, variables) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        {
            data.model,
            data.x,
            data.y,
            data.z,
            type(data.rx) == "number" and data.rx or 0.0,
            type(data.ry) == "number" and data.ry or 0.0,
            type(data.rz) == "number" and data.rz or 0.0,
            type(data.dimension) == "number" and data.dimension or 0,
            _G.APIServer.resource,
            type(data.variables) == "table" and json.encode(data.variables) or json.encode({})
        }
    )
    if type(insertId) == "number" then
        local dataResponse = exports["oxmysql"]:single_async(
            "SELECT * FROM avp_lib_objects WHERE id = ?",
            { insertId }
        )
        if dataResponse then
            return self:createObject(dataResponse)
        end
    end
end

function ObjectManager:loadObjectsFromSql()
    exports["oxmysql"]:query("SELECT * FROM avp_lib_objects WHERE resource = ?", {
        _G.APIServer.resource
    }, function(responseData)
        if responseData and type(responseData) == "table" then
            for i = 1, #responseData do
                self:createObject(responseData[i])
            end
        end
    end)
end

---@param vec3 vector3
---@param model string | nil
---@param range number
---@param dimension number
function ObjectManager:getObjectsInRange(vec3, model, range, dimension)
    ---@type API_Server_ObjectBase[]
    local collectedObjects = {}

    if type(vec3) == "vector3" then
        for k, v in pairs(self.objects) do
            if v.data.dimension == dimension then
                if model then
                    if v.data.model == model then
                        local dist = v:dist(vec3)
                        if dist < range then
                            collectedObjects[#collectedObjects + 1] = v
                        end
                    end
                else
                    local dist = v:dist(vec3)
                    if dist < range then
                        collectedObjects[#collectedObjects + 1] = v
                    end
                end
            end
        end
    end

    return collectedObjects
end

---@param vec3 vector3
---@param model string | string[] | nil
---@param range number
---@param dimension number
---@return API_Server_ObjectBase | nil
function ObjectManager:getNearestObject(vec3, model, range, dimension)
    local rangeMeter = range
    local closest = nil

    if type(vec3) == "vector3" then
        for k, v in pairs(self.objects) do
            if v.data.dimension == dimension then
                if model then
                    if type(model) == "table" then
                        for i = 1, #model do
                            if v.data.model == model[i] then
                                local dist = v:dist(vec3)
                                if dist < rangeMeter then
                                    rangeMeter = dist
                                    closest = v
                                end
                            end
                        end
                    else
                        if v.data.model == model then
                            local dist = v:dist(vec3)
                            if dist < rangeMeter then
                                rangeMeter = dist
                                closest = v
                            end
                        end
                    end
                else
                    local dist = v:dist(vec3)
                    if dist < rangeMeter then
                        rangeMeter = dist
                        closest = v
                    end
                end
            end
        end
    end

    return closest
end

return ObjectManager

end)
__bundle_register("server.gameobjects.object.object", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class ISQLObject
---@field id? number
---@field model string
---@field x number
---@field y number
---@field z number
---@field rx number
---@field ry number
---@field rz number
---@field variables table
---@field dimension number
---@field resource string

---@class API_Server_ObjectBase
---@field data ISQLObject
---@field remoteId number
local Object = {}
Object.__index = Object

---@param remoteId number
---@param data ISQLObject
Object.new = function(remoteId, data)
    local self = setmetatable({}, Object)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

---@private
function Object:__init__()
    TriggerEvent(_G.APIServer.resource .. ":onObjectCreated", self)

    --     TriggerClientEvent("AquiverLib:Object:Create", -1, self.remoteId, self.data)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:getVector3Position()
    return vector3(self.data.x, self.data.y, self.data.z)
end

function Object:getVector3Rotation()
    return vector3(self.data.rx, self.data.ry, self.data.rz)
end

---@param vec3 vector3
function Object:dist(vec3)
    return #(self:getVector3Position() - vectro3(vec3.x, vec3.y, vec3.z))
end

function Object:getVar(key)
    return self.data.variables[key]
end

function Object:setVar(key, value)
    if self.data.variables[key] == value then return end

    self.data.variables[key] = value

    --         TriggerClientEvent("AquiverLib:Object:Update:VariableKey",
    --             -1,
    --             self.remoteId,
    --             key,
    --             self.data.variables[key]
    --         )

    TriggerEvent(_G.APIServer.resource .. ":onObjectVariableChange", self, key, value)

    -- // TODO: Performance increase here with some timeout.
    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET variables = ? WHERE id = ?", {
            json.encode(self.data.variables),
            self.data.id
        })
    end
end

---@param vec3 vector3
function Object:setPosition(vec3)
    if self.data.x == vec3.x and self.data.y == vec3.y and self.data.z == vec3.z then return end

    self.data.x = vec3.x
    self.data.y = vec3.y
    self.data.z = vec3.z

    -- TriggerClientEvent("AquiverLib:Object:Update:Position",
    --     -1,
    --     self.remoteId,
    --     self.data.x,
    --     self.data.y,
    --     self.data.z
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET x = ?, y = ?, z = ? WHERE id = ?", {
            self.data.x,
            self.data.y,
            self.data.z,
            self.data.id
        })
    end
end

---@param vec3 vector3
function Object:setRotation(vec3)
    if self.data.rx == vec3.x and self.data.ry == vec3.y and self.data.rz == vec3.z then return end

    self.data.rx = vec3.x
    self.data.ry = vec3.y
    self.data.rz = vec3.z

    -- TriggerClientEvent("AquiverLib:Object:Update:Rotation",
    --     -1,
    --     self.remoteId,
    --     self.data.rx,
    --     self.data.ry,
    --     self.data.rz
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET rx = ?, ry = ?, rz = ? WHERE id = ?", {
            self.data.rx,
            self.data.ry,
            self.data.rz,
            self.data.id
        })
    end
end

---@param model string
function Object:setModel(model)
    if self.data.model == model then return end

    self.data.model = model

    -- TriggerClientEvent("AquiverLib:Object:Update:Model",
    --     -1,
    --     self.remoteId,
    --     self.data.model
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET model = ? WHERE id = ?", {
            self.data.model,
            self.data.id
        })
    end
end

function Object:destroy()
    if _G.APIServer.Managers.ObjectManager.objects[self.remoteId] then
        _G.APIServer.Managers.ObjectManager.objects[self.remoteId] = nil
    end

    TriggerEvent(_G.APIServer.resource .. "onObjectDestroyed", self)
    --         TriggerClientEvent("AquiverLib:Object:Destroy", self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed object (%d, %s)", self.remoteId, self.data.model)
    )
end

return Object

end)
__bundle_register("server.managers.player_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("server.gameobjects.player.player", function(require, _LOADED, __bundle_register, __bundle_modules)
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

    TriggerEvent(_G.APIServer.resource .. ":onPlayerCreated", self)
end

function Player:getPed()
    return GetPlayerPed(self.playerId)
end

---@param key string
---@param value any
function Player:setVar(key, value)
    if self.variables[key] == value then return end

    self.variables[key] = value

    TriggerClientEvent(_G.APIServer.resource .. ":onPlayerVariableChange", self.playerId, key, value)
    TriggerEvent(_G.APIServer.resource .. ":onPlayerVariableChange", self, key, value)
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

end)
__bundle_register("server.config", function(require, _LOADED, __bundle_register, __bundle_modules)
local CONFIG = {}

return CONFIG

end)
__bundle_register("shared.shared", function(require, _LOADED, __bundle_register, __bundle_modules)
local Helpers = require("shared.helpers.helpers")
local Config = require("shared.config")

local Shared = {}
Shared.Helpers = Helpers
Shared.CONFIG = Config

return Shared

end)
__bundle_register("shared.config", function(require, _LOADED, __bundle_register, __bundle_modules)
local CONFIG = {}

return CONFIG

end)
__bundle_register("shared.helpers.helpers", function(require, _LOADED, __bundle_register, __bundle_modules)
local Interval = require("shared.helpers.intervals.interval_class")
local Logger = require("shared.helpers.logger.logger")

local Helpers = {
    Interval = Interval,
    Logger = Logger
}

return Helpers

end)
__bundle_register("shared.helpers.logger.logger", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = {}

---@param content any
---@param toJSON? boolean
function Logger:debug(content, toJSON)
    local f = ""
    f = "->" .. " ^3"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:error(content, toJSON)
    local f = ""
    f = "->" .. " ^1"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:info(content, toJSON)
    local f = ""
    f = "->" .. " ^5"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

return Logger

end)
__bundle_register("shared.helpers.intervals.interval_class", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Interval_Class
---@field timeMS number
---@field cb function
---@field private isStarted boolean
---@field threadId number
local Interval = {}
Interval.__index = Interval

---@param timeMS number
---@param cb function
Interval.new = function(timeMS, cb)
    local self = setmetatable({}, Interval)

    self.timeMS = timeMS
    self.cb = cb
    self.isStarted = false

    return self
end

function Interval:start()
    if self.isStarted then return end

    Citizen.CreateThreadNow(function(id)
        self.isStarted = true
        self.threadId = id

        repeat
            Citizen.Wait(self.timeMS)
            self.cb()
        until not self.isStarted
    end)
end

function Interval:stop()
    if not self.isStarted then return end

    self.isStarted = false
end

return Interval

end)
return __bundle_require("__root")