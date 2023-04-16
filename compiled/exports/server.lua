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
_G.APIServer.CONFIG = Config

-- Events needs to be loaded after the _G.APIServer initialized.
require("server.events.events")

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
    if _G.APIShared.resource ~= resourceName then return end
    _G.APIServer.Managers.PlayerManager:onResourceStart()
end)

end)
__bundle_register("server.events.events", function(require, _LOADED, __bundle_register, __bundle_modules)
require("server.events.events_object")
require("server.events.events_ped")
require("server.events.events_actionshape")
require("server.events.events_blips")
require("server.events.events_player")

end)
__bundle_register("server.events.events_player", function(require, _LOADED, __bundle_register, __bundle_modules)
-- menuExecuteCallback
RegisterNetEvent("menuExecuteCallback", function(index)
    local playerId = source
    local player = _G.APIServer.Managers.PlayerManager:getPlayer(playerId)
    if not player then return end

    if player.currentMenuData and player.currentMenuData.menus[index] and type(player.currentMenuData.menus[index].callback) == "function" then
        player.currentMenuData.menus[index].callback()
    end
end)

end)
__bundle_register("server.events.events_blips", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "blips:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.BlipManager.blips) do
        v:createForPlayer(playerId)
    end
end)

end)
__bundle_register("server.events.events_actionshape", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.ActionshapeManager.shapes) do
        v:createForPlayer(playerId)
    end
end)

end)
__bundle_register("server.events.events_ped", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "peds:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.PedManager.peds) do
        v:createForPlayer(playerId)
    end
end)

end)
__bundle_register("server.events.events_object", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "objects:request:data", function()
    local playerId = source

    for k, v in pairs(_G.APIServer.Managers.ObjectManager.objects) do
        v:createForPlayer(playerId)
    end
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
local ActionshapeManager = require("server.managers.actionshape_manager")
local PedManager = require("server.managers.ped_manager")

local Managers = {
    PlayerManager = PlayerManager.new(),
    ObjectManager = ObjectManager.new(),
    BlipManager = BlipManager.new(),
    ActionshapeManager = ActionshapeManager.new(),
    PedManager = PedManager.new()
}

return Managers

end)
__bundle_register("server.managers.ped_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ped = require("server.gameobjects.ped.ped")

---@class PedManager
---@field peds table<number, API_Server_PedBase>
---@field remoteIdCounter number
local PedManager = {}
PedManager.__index = PedManager

PedManager.new = function()
    local self = setmetatable({}, PedManager)

    self.peds = {}
    self.remoteIdCounter = 0

    return self
end

---@param data IPed
function PedManager:createPed(data)
    local remoteId = self:getNextRemoteId()

    self.peds[remoteId] = Ped.new(remoteId, data)

    return self.peds[remoteId]
end

function PedManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function PedManager:getPed(remoteId)
    return self.peds[remoteId]
end

return PedManager

end)
__bundle_register("server.gameobjects.ped.ped", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class IPed
---@field pos vector3
---@field heading number
---@field model string
---@field dimension number
---@field scenario? string
---@field animDict? string
---@field animName? string
---@field animFlag? number
---@field questionMark? boolean
---@field name? string

---@class API_Server_PedBase
---@field data IPed
---@field remoteId number
local Ped = {}
Ped.__index = Ped

---@param remoteId number
---@param data IPed
Ped.new = function(remoteId, data)
    local self = setmetatable({}, Ped)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

function Ped:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new ped (%d, %s)", self.remoteId, self.data.model)
    )

    self:createForPlayer(-1)

    _G.APIShared.EventHandler:TriggerEvent("onPedCreated", self)
end

function Ped:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "peds:create", source, self.remoteId, self.data)
end

---@param scenario string
function Ped:setScenario(scenario)
    if self.data.scenario == scenario then return end

    self.data.scenario = scenario

    TriggerClientEvent(_G.APIShared.resource .. "peds:set:scenario", -1, self.remoteId, self.data.scenario)
end

---@param dict string
---@param name string
---@param flag number
function Ped:playAnimation(dict, name, flag)
    self.data.animDict = dict
    self.data.animName = name
    self.data.animFlag = flag

    TriggerClientEvent(_G.APIShared.resource .. "peds:set:animation", -1, self.remoteId, dict, name, flag)
end

function Ped:destroy()
    if _G.APIServer.Managers.PedManager.peds[self.remoteId] then
        _G.APIServer.Managers.PedManager.peds[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onPedDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "peds:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed ped (%d, %s)", self.remoteId, self.data.model)
    )
end

return Ped

end)
__bundle_register("server.managers.actionshape_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Actionshape = require("server.gameobjects.actionshape.actionshape")

---@class ActionshapeManager
---@field shapes table<number, API_Server_ActionshapeBase>
---@field remoteIdCounter number
local ActionshapeManager = {}
ActionshapeManager.__index = ActionshapeManager

ActionshapeManager.new = function()
    local self = setmetatable({}, ActionshapeManager)

    self.shapes = {}
    self.remoteIdCounter = 0

    return self
end

---@param data IActionShape
function ActionshapeManager:createActionshape(data)
    local remoteId = self:getNextRemoteId()

    self.shapes[remoteId] = Actionshape.new(remoteId, data)

    return self.shapes[remoteId]
end

function ActionshapeManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function ActionshapeManager:getActionshape(remoteId)
    return self.shapes[remoteId]
end

return ActionshapeManager

end)
__bundle_register("server.gameobjects.actionshape.actionshape", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class IActionShape
---@field pos vector3
---@field color { r:number; g:number; b:number; a:number; }
---@field sprite number
---@field range number
---@field streamDistance number
---@field dimension number
---@field bobUpAndDown boolean
---@field rotateMarker boolean
---@field markerSize number
---@field variables table

---@class API_Server_ActionshapeBase
---@field data IActionShape
---@field remoteId number
local Actionshape = {}
Actionshape.__index = Actionshape

---@param remoteId number
---@param data IActionShape
Actionshape.new = function(remoteId, data)
    local self = setmetatable({}, Actionshape)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

function Actionshape:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new actionshape (%d)", self.remoteId)
    )

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeCreated", self)
    self:createForPlayer(-1)
end

function Actionshape:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:create", source, self.remoteId, self.data)
end

---@param vec3 vector3
function Actionshape:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos.x = vec3.x
    self.data.pos.y = vec3.y
    self.data.pos.z = vec3.z

    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:set:position",
        -1,
        self.remoteId,
        self.data.pos.x,
        self.data.pos.y,
        self.data.pos.z
    )
end

function Actionshape:destroy()
    if _G.APIServer.Managers.ActionshapeManager.shapes[self.remoteId] then
        _G.APIServer.Managers.ActionshapeManager.shapes[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed actionshape (%d)", self.remoteId)
    )
end

return Actionshape

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
    self.remoteIdCounter = 0

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

    _G.APIShared.EventHandler:TriggerEvent("onBlipCreated", self)

    self:createForPlayer(-1)
end

function Blip:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "blips:create", source, self.remoteId, self.data)
end

---@param colorId number
function Blip:setColor(colorId)
    if self.data.color == colorId then return end

    self.data.color = colorId

    TriggerClientEvent(_G.APIShared.resource .. "blips:set:color", -1, self.remoteId, colorId)
end

---@param vec3 vector3
function Blip:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos = vec3

    TriggerClientEvent(_G.APIShared.resource .. "blips:set:position", -1, self.remoteId, x, y, z)
end

function Blip:destroy()
    if _G.APIServer.Managers.BlipManager.blips[self.remoteId] then
        _G.APIServer.Managers.BlipManager.blips[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onBlipDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "blips:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed blip (%d)", self.remoteId)
    )
end

return Blip

end)
__bundle_register("server.managers.object_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Object = require("server.gameobjects.object.object")

---@class Server_ObjectManager
---@field objects table<number, API_Server_ObjectBase>
---@field remoteIdCounter number
local ObjectManager = {}
ObjectManager.__index = ObjectManager

ObjectManager.new = function()
    local self = setmetatable({}, ObjectManager)

    self.objects = {}
    self.remoteIdCounter = 0

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
            _G.APIShared.resource,
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
        _G.APIShared.resource
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

    if type(self.data.variables) == "string" then
        self.data.variables = json.decode(self.data.variables)
    end

    self.remoteId = remoteId

    self:__init__()

    return self
end

---@private
function Object:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onObjectCreated", self)

    -- Create for everyone.
    self:createForPlayer(-1)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "objects:create", source, self.remoteId, self.data)
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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:variablekey",
        -1,
        self.remoteId,
        key,
        value
    )

    _G.APIShared.EventHandler:TriggerEvent("onObjectVariableChange", self, key, value)

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:position",
        -1,
        self.remoteId,
        self.data.x,
        self.data.y,
        self.data.z
    )

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:rotation",
        -1,
        self.remoteId,
        self.data.rx,
        self.data.ry,
        self.data.rz
    )

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:model",
        -1,
        self.remoteId,
        self.data.model
    )

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

    _G.APIShared.EventHandler:TriggerEvent("onObjectDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "objects:destroy", -1, self.remoteId)

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
local PlayerState = Player

---@class API_Server_PlayerBase
---@field playerId number
---@field private variables table<string, any>
---@field currentMenuData IMenu
local Player = {}
Player.__index = Player

Player.new = function(playerId)
    local self = setmetatable({}, Player)

    self.variables = {}
    self.playerId = playerId
    self.currentMenuData = nil

    self:__init__()

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
    local oldDimension = self:getDimension()
    if oldDimension == dimension then return end

    PlayerState(self.playerId).state:set("dimension", dimension, true)

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
    TriggerClientEvent("aquiver-lib:sendNuiMessage", self.playerId, jsonContent)
end

function Player:addAttachment(attachmentName)
    PlayerState(self.playerId).state:set("attachments%" .. attachmentName, true, true)
end

function Player:removeAttachment(attachmentName)
    PlayerState(self.playerId).state:set("attachment%" .. attachmentName, false, true)
end

function Player:hasAttachment(attachmentName)
    return PlayerState(self.playerId).state["attachment%" .. attachmentName]
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

---@param menuData IMenu
function Player:menuOpen(menuData)
    self.currentMenuData = menuData

    local nuiFormat = {
        header = menuData.header,
        executeInResource = _G.APIShared.resource,
        menus = {}
    }
    for k, v in pairs(menuData.menus) do
        nuiFormat.menus[#nuiFormat.menus + 1] = {
            icon = v.icon,
            name = v.name
        }
    end

    self:sendApiMessage({
        event = "MenuOpen",
        menuData = nuiFormat
    })
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
local EventHandler = require("shared.eventhandler.evenhandler")

local Shared = {}
Shared.resource = GetCurrentResourceName() --[[@as string]]
Shared.Helpers = Helpers
Shared.CONFIG = Config
Shared.EventHandler = EventHandler.new()

return Shared

end)
__bundle_register("shared.eventhandler.evenhandler", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class EventHandler
---@field events table<string, fun(...)[]>
local EventHandler = {}
EventHandler.__index = EventHandler

EventHandler.new = function()
    local self = setmetatable({}, EventHandler)

    self.events = {}

    return self
end

--- This event only added in the current resource.
--- It can pass the metatables in the arguments bypassing the fivem AddEventHandler
---@param eventName string
---@param cb fun(...)
function EventHandler:AddEvent(eventName, cb)
    if type(self.events[eventName]) ~= "table" then
        self.events[eventName] = {}
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Registered new event: %s", eventName)
    )

    self.events[eventName][#self.events[eventName] + 1] = cb
end

--- This function only trigger on local. (so server->server and client->client)
--- It can pass the metatables in the arguments bypassing the fivem AddEventHandler
---@param eventName string
---@param ... any
function EventHandler:TriggerEvent(eventName, ...)
    if type(self.events[eventName]) ~= "table" then return end

    for i = 1, #self.events[eventName] do
        self.events[eventName][i](...)
    end
end

return EventHandler

end)
__bundle_register("shared.config", function(require, _LOADED, __bundle_register, __bundle_modules)
local CONFIG = {}

CONFIG.DebugEnabled = false

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
    if not _G.APIShared.CONFIG.DebugEnabled then return end

    local f = ""
    f = string.format("[%s] -> ^3", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:error(content, toJSON)
    local f = ""
    f = string.format("[%s] -> ^1", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:info(content, toJSON)
    local f = ""
    f = string.format("[%s] -> ^5", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

return Logger

end)
__bundle_register("shared.helpers.intervals.interval_class", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Interval_Class
---@field timeMS number
---@field private cb function
---@field private isStarted boolean
---@field private threadId number
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