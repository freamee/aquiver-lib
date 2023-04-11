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

local Config = require("client.config")
local Managers = require("client.managers.managers")

_G.APIShared = Shared

_G.APIClient = {}
_G.APIClient.Managers = Managers
_G.APIClient.resource = GetCurrentResourceName() --[[@as string]]
_G.APIClient.CONFIG = Config

-- Events needs to be loaded after the _G.APIClient initialized.
require("client.events.events")

end)
__bundle_register("client.events.events", function(require, _LOADED, __bundle_register, __bundle_modules)
require("client.events.events_object")

end)
__bundle_register("client.events.events_object", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIClient.resource .. "objects:create", function(remoteId, data)
    _G.APIClient.Managers.ObjectManager:createObject(remoteId, data)
end)
RegisterNetEvent(_G.APIClient.resource .. "objects:destroy", function(remoteId)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:destroy()
end)
RegisterNetEvent(_G.APIClient.resource .. "objects:set:position", function(remoteId, x, y, z)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setPosition(vector3(x, y, z))
end)
RegisterNetEvent(_G.APIClient.resource .. "objects:set:rotation", function(remoteId, rx, ry, rz)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setRotation(vector3(rx, ry, rz))
end)
RegisterNetEvent(_G.APIClient.resource .. "objects:set:model", function(remoteId, model)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setModel(model)
end)
RegisterNetEvent(_G.APIClient.resource .. "objects:set:variablekey", function(remoteId, key, value)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setVar(key, value)
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIClient.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.ObjectManager.objects) do
        v:destroy()
    end
end)

-- Requesting objects from server on client load.
Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIClient.resource .. "objects:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(_G.APIClient.Managers.ObjectManager.objects) do
            local dist = v:dist(playerCoords)
            if dist < 20.0 then
                v:addStream()
            else
                v:removeStream()
            end
        end

        Citizen.Wait(1000)
    end
end)

end)
__bundle_register("client.managers.managers", function(require, _LOADED, __bundle_register, __bundle_modules)
local ObjectManager = require("client.managers.object_manager")

local Managers = {
    ObjectManager = ObjectManager.new()
}

return Managers

end)
__bundle_register("client.managers.object_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Object = require("client.gameobjects.objects.object")

---@class Client_ObjectManager
---@field objects table<number, API_Client_ObjectBase>
local ObjectManager = {}
ObjectManager.__index = ObjectManager

ObjectManager.new = function()
    local self = setmetatable({}, ObjectManager)

    self.objects = {}

    return self
end

---@param remoteId number
---@param data ISQLObject
function ObjectManager:createObject(remoteId, data)
    if self.objects[remoteId] then
        return self.objects[remoteId]
    end

    self.objects[remoteId] = Object.new(remoteId, data)

    return self.objects[remoteId]
end

function ObjectManager:getObject(remoteId)
    return self.objects[remoteId]
end

return ObjectManager

end)
__bundle_register("client.gameobjects.objects.object", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class API_Client_ObjectBase
---@field data ISQLObject
---@field remoteId number
---@field isStreamed boolean
---@field objectHandle number
local Object = {}
Object.__index = Object

---@param remoteId number
---@param data ISQLObject
Object.new = function(remoteId, data)
    local self = setmetatable({}, Object)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.objectHandle = nil

    self:__init__()

    return self
end

function Object:__init__()
    TriggerEvent(_G.APIClient.resource .. ":onObjectCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    local modelHash = GetHashKey(self.data.model)
    if not IsModelValid(modelHash) then return end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local obj = CreateObjectNoOffset(modelHash, self:getVector3Position(), false, false, false)
    SetEntityRotation(obj, self:getVector3Rotation(), 2, false)
    FreezeEntityPosition(obj, true)

    self.objectHandle = obj

    TriggerEvent(_G.APIClient.resource .. "onObjectStreamedIn", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Object streamed in (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:removeStream()
    if not self.isStreamed then return end

    if DoesEntityExist(self.objectHandle) then
        DeleteEntity(self.objectHandle)
    end

    self.isStreamed = false

    TriggerEvent(_G.APIClient.resource .. "onObjectStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Object streamed out (%d, %s)", self.remoteId, self.data.model)
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
    return #(self:getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
end

function Object:setVar(key, value)
    if self.data.variables[key] == value then return end

    self.data.variables[key] = value

    TriggerEvent(_G.APIClient.resource .. ":onObjectVariableChange", self, key, value)
end

---@param vec3 vector3
function Object:setPosition(vec3)
    if self.data.x == vec3.x and self.data.y == vec3.y and self.data.z == vec3.z then return end

    self.data.x = vec3.x
    self.data.y = vec3.y
    self.data.z = vec3.z

    if DoesEntityExist(self.objectHandle) then
        SetEntityCoords(self.objectHandle, self:getVector3Position(), false, false, false, false)
    end
end

---@param vec3 vector3
function Object:setRotation(vec3)
    if self.data.rx == vec3.x and self.data.ry == vec3.y and self.data.rz == vec3.z then return end

    self.data.rx = vec3.x
    self.data.ry = vec3.y
    self.data.rz = vec3.z

    if DoesEntityExist(self.objectHandle) then
        SetEntityRotation(self.objectHandle, self:getVector3Rotation(), 2, false)
    end
end

---@param model string
function Object:setModel(model)
    if self.data.model == model then return end

    self.data.model = model

    if self.isStreamed then
        self:removeStream()
        self:addStream()
    end
end

function Object:destroy()
    if _G.APIClient.Managers.ObjectManager.objects[self.remoteId] then
        _G.APIClient.Managers.ObjectManager.objects[self.remoteId] = nil
    end

    TriggerEvent(_G.APIClient.resource .. "onObjectDestroyed", self)

    if DoesEntityExist(self.objectHandle) then
        DeleteEntity(self.objectHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed object (%d, %s)", self.remoteId, self.data.model)
    )
end

return Object

end)
__bundle_register("client.config", function(require, _LOADED, __bundle_register, __bundle_modules)
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