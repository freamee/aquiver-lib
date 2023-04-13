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
local Helpers = require("client.helpers.helpers")
local Game = require("client.game.game")

_G.APIShared = Shared

_G.APIClient = {}
_G.APIClient.Game = Game
_G.APIClient.Managers = Managers
_G.APIClient.Helpers = Helpers
_G.APIClient.CONFIG = Config

-- Events needs to be loaded after the _G.APIClient initialized.
require("client.events.events")

end)
__bundle_register("client.events.events", function(require, _LOADED, __bundle_register, __bundle_modules)
require("client.events.events_object")
require("client.events.events_ped")
require("client.events.events_actionshape")
require("client.events.events_blip")

end)
__bundle_register("client.events.events_blip", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "blips:create", function(remoteId, data)
    _G.APIClient.Managers.BlipManager:createBlip(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:destroy", function(remoteId)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:set:position", function(remoteId, x, y, z)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:setPosition(x, y, z)
end)
RegisterNetEvent(_G.APIShared.resource .. "blips:set:color", function(remoteId, colorId)
    local blip = _G.APIClient.Managers.BlipManager:getBlip(remoteId)
    if not blip then return end
    blip:setColor(colorId)
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.BlipManager.blips) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "blips:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

end)
__bundle_register("client.events.events_actionshape", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:create", function(remoteId, data)
    _G.APIClient.Managers.ActionshapeManager:createActionshape(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:destroy", function(remoteId)
    local actionshape = _G.APIClient.Managers.ActionshapeManager:getActionshape(remoteId)
    if not actionshape then return end
    actionshape:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "actionshapes:set:position", function(remoteId, x, y, z)
    local actionshape = _G.APIClient.Managers.ActionshapeManager:getActionshape(remoteId)
    if not actionshape then return end
    actionshape:setPosition(vector3(x, y, z))
end)

AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.ActionshapeManager.shapes) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "actionshapes:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(_G.APIClient.Managers.ActionshapeManager.shapes) do
            local dist = v:dist(playerCoords)
            if dist < v.data.streamDistance then
                v:addStream()
            else
                v:removeStream()
            end

            if dist < v.data.range then
                v:onEnter()
            else
                v:onLeave()
            end
        end

        Citizen.Wait(1000)
    end
end)

end)
__bundle_register("client.events.events_ped", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "peds:create", function(remoteId, data)
    _G.APIClient.Managers.PedManager:createPed(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:destroy", function(remoteId)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:set:scenario", function(remoteId, scenario)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:setScenario(scenario)
end)
RegisterNetEvent(_G.APIShared.resource .. "peds:set:animation", function(remoteId, dict, name, flag)
    local ped = _G.APIClient.Managers.PedManager:getPed(remoteId)
    if not ped then return end
    ped:setAnimation(dict, name, flag)
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.PedManager.peds) do
        v:destroy()
    end
end)

Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "peds:request:data")
            break
        end

        Citizen.Wait(500)
    end
end)

-- STREAMING HANDLER.
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(_G.APIClient.Managers.PedManager.peds) do
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
__bundle_register("client.events.events_object", function(require, _LOADED, __bundle_register, __bundle_modules)
RegisterNetEvent(_G.APIShared.resource .. "objects:create", function(remoteId, data)
    _G.APIClient.Managers.ObjectManager:createObject(remoteId, data)
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:destroy", function(remoteId)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:destroy()
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:position", function(remoteId, x, y, z)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setPosition(vector3(x, y, z))
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:rotation", function(remoteId, rx, ry, rz)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setRotation(vector3(rx, ry, rz))
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:model", function(remoteId, model)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setModel(model)
end)
RegisterNetEvent(_G.APIShared.resource .. "objects:set:variablekey", function(remoteId, key, value)
    local object = _G.APIClient.Managers.ObjectManager:getObject(remoteId)
    if not object then return end
    object:setVar(key, value)
end)

-- Destroy the objects when the resource is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    for k, v in pairs(_G.APIClient.Managers.ObjectManager.objects) do
        v:destroy()
    end
end)

-- Requesting objects from server on client load.
Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            -- Request Data from server.
            TriggerServerEvent(_G.APIShared.resource .. "objects:request:data")
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
__bundle_register("client.game.game", function(require, _LOADED, __bundle_register, __bundle_modules)
local Raycast = require("client.game.raycast")

local Game = {
    Raycast = Raycast.new()
}

return Game

end)
__bundle_register("client.game.raycast", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class Client_RaycastSystem
---@field private isEnabled boolean
---@field private currentHitHandle number | nil
---@field renderInterval Interval_Class
---@field findInterval Interval_Class
local Raycast = {}
Raycast.__index = Raycast

Raycast.new = function()
    local self = setmetatable({}, Raycast)

    self.isEnabled = false
    self.currentHitHandle = nil

    Citizen.CreateThread(function()
        self.renderInterval = _G.APIShared.Helpers.Interval.new(1, function()
            _G.APIClient.Helpers:drawText2D(0.5, 0.5, "Ray")
        end)
        self.findInterval = _G.APIShared.Helpers.Interval.new(300, function()
            local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
            local destination = coords + normal * 8
            local handle = StartShapeTestCapsule(
                coords.x,
                coords.y,
                coords.z,
                destination.x,
                destination.y,
                destination.z,
                0.15,
                16,
                PlayerPedId(),
                4
            )

            local _, hit, endCoords, surfaceNormal, hitHandle = GetShapeTestResult(handle)

            if hit and DoesEntityExist(hitHandle) then
                self:setEntityHandle(hitHandle)
            else
                self:setEntityHandle(nil)
            end
        end)
        -- self.renderInterval = _G.SharedGlobals.Helpers.Interval.new(1, function()
        --     _G.ClientGlobals.Helpers.UtilsHelper:drawSprite2D({
        --         screenX = 0.5,
        --         screenY = 0.5,
        --         textureDict = "mphud",
        --         textureName = "spectating",
        --         scale = 0.75,
        --         rotation = 0,
        --         r = 255,
        --         g = 255,
        --         b = 255,
        --         a = 200
        --     })
        -- end)
    end)

    return self
end

---@param handleId number | nil
function Raycast:setEntityHandle(handleId)
    if self.currentHitHandle == handleId then return end

    self.currentHitHandle = handleId

    if self.currentHitHandle then
        if self.renderInterval then
            self.renderInterval:start()
        end
    else
        if self.renderInterval then
            self.renderInterval:stop()
        end
    end
end

---@param state boolean
function Raycast:enable(state)
    if self.isEnabled == state then return end

    self.isEnabled = state

    if self.isEnabled then
        if self.findInterval then
            self.findInterval:start()
        end
    else
        if self.findInterval then
            self.findInterval:stop()
        end
        self:setEntityHandle(nil)
    end
end

return Raycast

end)
__bundle_register("client.helpers.helpers", function(require, _LOADED, __bundle_register, __bundle_modules)
local Helpers = {}

---@param x number
---@param y number
---@param z number
---@param text string
---@param size? number Default: 0.25
---@param font? number Default: 0
function Helpers:drawText3D(x, y, z, text, size, font)
    size = type(size) == "number" and size or 0.25
    font = type(font) == "number" and font or 0

    SetTextScale(size, size)
    SetTextFont(font)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 100)
    -- SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param x number
---@param y number
---@param text string
---@param size? number Default: 0.25
---@param font? number Default: 0
function Helpers:drawText2D(x, y, text, size, font)
    size = type(size) == "number" and size or 0.25
    font = type(font) == "number" and font or 0

    SetTextFont(font)
    SetTextProportional(false)
    SetTextScale(size, size)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 100)
    SetTextDropShadow()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

return Helpers

end)
__bundle_register("client.managers.managers", function(require, _LOADED, __bundle_register, __bundle_modules)
local ObjectManager = require("client.managers.object_manager")
local PedManager = require("client.managers.ped_manager")
local ActionshapeManager = require("client.managers.actionshape_manager")
local BlipManager = require("client.managers.blip_manager")

local Managers = {
    ObjectManager = ObjectManager.new(),
    PedManager = PedManager.new(),
    ActionshapeManager = ActionshapeManager.new(),
    BlipManager = BlipManager.new()
}

return Managers

end)
__bundle_register("client.managers.blip_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Blip = require("client.gameobjects.blip.blip")

---@class Client_BlipManager
---@field blips table<number, API_Client_BlipBase>
local BlipManager = {}
BlipManager.__index = BlipManager

BlipManager.new = function()
    local self = setmetatable({}, BlipManager)

    self.blips = {}

    return self
end

---@param remoteId number
---@param data IBlip
function BlipManager:createBlip(remoteId, data)
    if self.blips[remoteId] then
        return self.blips[remoteId]
    end

    self.blips[remoteId] = Blip.new(remoteId, data)

    return self.blips[remoteId]
end

function BlipManager:getBlip(remoteId)
    return self.blips[remoteId]
end

return BlipManager

end)
__bundle_register("client.gameobjects.blip.blip", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class API_Client_BlipBase
---@field data IBlip
---@field remoteId number
---@field blipHandle number
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

function Blip:__init__()
    local blip = AddBlipForCoord(self.data.pos.x, self.data.pos.y, self.data.pos.z)
    SetBlipSprite(blip, self.data.sprite)
    SetBlipDisplay(blip, self.data.display)
    SetBlipScale(blip, self.data.scale)
    SetBlipAlpha(blip, self.data.alpha)
    SetBlipAsShortRange(blip, self.data.shortRange)
    SetBlipColour(blip, self.data.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.data.name)
    EndTextCommandSetBlipName(blip)

    self.blipHandle = blip

    _G.APIShared.EventHandler:TriggerEvent("onBlipCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new blip (%d)", self.remoteId)
    )
end

function Blip:setPosition(x, y, z)
    if self.data.pos.x == x and self.data.pos.y == y and self.data.pos.z == z then return end

    self.data.pos.x = x
    self.data.pos.y = y
    self.data.pos.z = z

    if DoesBlipExist(self.blipHandle) then
        SetBlipCoords(self.blipHandle, x, y, z)
    end
end

function Blip:setColor(colorId)
    if self.data.color == colorId then return end

    self.data.color = colorId

    if DoesBlipExist(self.blipHandle) then
        SetBlipColour(self.blipHandle, colorId)
    end
end

function Blip:destroy()
    if _G.APIClient.Managers.BlipManager.blips[self.remoteId] then
        _G.APIClient.Managers.BlipManager.blips[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onBlipDestroyed", self)

    if DoesBlipExist(self.blipHandle) then
        RemoveBlip(self.blipHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed blip (%d)", self.remoteId)
    )
end

return Blip

end)
__bundle_register("client.managers.actionshape_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Actionshape = require("client.gameobjects.actionshape.actionshape")

---@class Client_ActionshapeManager
---@field shapes table<number, API_Client_ActionshapeBase>
local ActionshapeManager = {}
ActionshapeManager.__index = ActionshapeManager

ActionshapeManager.new = function()
    local self = setmetatable({}, ActionshapeManager)

    self.shapes = {}

    return self
end

---@param remoteId number
---@param data IActionShape
function ActionshapeManager:createActionshape(remoteId, data)
    if self.shapes[remoteId] then
        return self.shapes[remoteId]
    end

    self.shapes[remoteId] = Actionshape.new(remoteId, data)

    return self.shapes[remoteId]
end

function ActionshapeManager:getActionshape(remoteId)
    return self.shapes[remoteId]
end

return ActionshapeManager

end)
__bundle_register("client.gameobjects.actionshape.actionshape", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class API_Client_ActionshapeBase
---@field data IActionShape
---@field remoteId number
---@field isStreamed boolean
---@field isEntered boolean
local Actionshape = {}
Actionshape.__index = Actionshape

---@param remoteId number
---@param data IActionShape
Actionshape.new = function(remoteId, data)
    local self = setmetatable({}, Actionshape)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.isEntered = false

    self:__init__()

    return self
end

function Actionshape:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onActionshapeCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new actionshape (%d)", self.remoteId)
    )
end

function Actionshape:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeStreamedIn", self)

    Citizen.CreateThread(function()
        while self.isStreamed do
            DrawMarker(
                self.data.sprite,
                vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z - 1.0),
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.0, 1.0, 1.0,
                self.data.color.r, self.data.color.g, self.data.color.b, self.data.color.a,
                false, false, 2, false, nil, nil, false
            )

            Citizen.Wait(1)
        end
    end)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Actionshape streamed in (%d)", self.remoteId)
    )
end

function Actionshape:removeStream()
    if not self.isStreamed then return end

    self.isStreamed = false

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Actionshape streamed out (%d)", self.remoteId)
    )
end

function Actionshape:onEnter()
    if self.isEntered then return end

    self.isEntered = true

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeEntered", self)
end

function Actionshape:onLeave()
    if not self.isEntered then return end

    self.isEntered = false

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeLeaved", self)
end

---@param vec3 vector3
function Actionshape:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos = vector3(vec3.x, vec3.y, vec3.z)
end

function Actionshape:getVector3Position()
    return vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z)
end

---@param vec3 vector3
function Actionshape:dist(vec3)
    return #(self:getVector3Position() - vec3)
end

function Actionshape:destroy()
    if _G.APIClient.Managers.ActionshapeManager.shapes[self.remoteId] then
        _G.APIClient.Managers.ActionshapeManager.shapes[self.remoteId] = nil
    end

    self:removeStream()

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeDestroyed", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed actionshape (%d)", self.remoteId)
    )
end

return Actionshape

end)
__bundle_register("client.managers.ped_manager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ped = require("client.gameobjects.ped.ped")

---@class Client_PedManager
---@field peds table<number, API_Client_PedBase>
local PedManager = {}
PedManager.__index = PedManager

PedManager.new = function()
    local self = setmetatable({}, PedManager)

    self.peds = {}

    return self
end

---@param remoteId number
---@param data IPed
function PedManager:createPed(remoteId, data)
    if self.peds[remoteId] then
        return self.peds[remoteId]
    end

    self.peds[remoteId] = Ped.new(remoteId, data)

    return self.peds[remoteId]
end

function PedManager:getPed(remoteId)
    return self.peds[remoteId]
end

return PedManager

end)
__bundle_register("client.gameobjects.ped.ped", function(require, _LOADED, __bundle_register, __bundle_modules)
---@class API_Client_PedBase
---@field data IPed
---@field remoteId number
---@field isStreamed boolean
---@field pedHandle number
local Ped = {}
Ped.__index = Ped

---@param remoteId number
---@param data IPed
Ped.new = function(remoteId, data)
    local self = setmetatable({}, Ped)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.pedHandle = nil

    self:__init__()

    return self
end

function Ped:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onPedCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new ped (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    local modelHash = GetHashKey(self.data.model)
    if not IsModelValid(modelHash) then return end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local ped = CreatePed(0, modelHash, self:getVector3Position(), self.data.heading, false, false)
    SetEntityCanBeDamaged(ped, false)
    SetPedAsEnemy(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedResetFlag(ped, 249, 1)
    SetPedConfigFlag(ped, 185, true)
    SetPedConfigFlag(ped, 108, true)
    SetPedConfigFlag(ped, 208, true)
    SetPedCanEvasiveDive(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedCanRagdoll(ped, false)
    SetPedDefaultComponentVariation(ped)

    SetEntityCoordsNoOffset(ped, self:getVector3Position(), false, false, false)
    SetEntityHeading(ped, self.data.heading)
    FreezeEntityPosition(ped, true)

    self.pedHandle = ped

    -- Re-apply scenario.
    self:setScenario(self.data.scenario)
    -- Re-apply animation.
    self:setAnimation(self.data.animDict, self.data.animName, self.data.animFlag)

    if self.data.questionMark or self.data.name then
        CreateThread(function()
            while self.isStreamed do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local dist = #(playerCoords - self:getVector3Position())
                if dist < 5 then
                    local onScreen = IsEntityOnScreen(self.pedHandle)

                    if self.data.questionMark then
                        DrawMarker(
                            32,
                            vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z + 1.35),
                            0, 0, 0,
                            0, 0, 0,
                            0.35, 0.35, 0.35,
                            255, 255, 0, 200,
                            true, false, 2, true, nil, nil, false
                        )
                    end

                    if self.data.name then
                        _G.APIClient.Helpers:drawText3D(
                            self.data.pos.x,
                            self.data.pos.y,
                            self.data.pos.z + 1,
                            self.data.name,
                            0.28
                        )
                    end

                    if not onScreen then
                        Wait(500)
                    end
                else
                    Wait(1000)
                end

                Wait(1)
            end
        end)
    end

    _G.APIShared.EventHandler:TriggerEvent("onPedStreamedIn", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Ped streamed in (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:removeStream()
    if not self.isStreamed then return end

    if DoesEntityExist(self.pedHandle) then
        DeleteEntity(self.pedHandle)
    end

    self.isStreamed = false

    _G.APIShared.EventHandler:TriggerEvent("onPedStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Ped streamed out (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:getVector3Position()
    return vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z)
end

---@param vec3 vector3
function Ped:dist(vec3)
    return #(self:getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
end

---@param scenario string
function Ped:setScenario(scenario)
    self.data.scenario = scenario

    if self.data.scenario and DoesEntityExist(self.pedHandle) then
        TaskStartScenarioInPlace(self.pedHandle, self.data.scenario, 0, false)
    end
end

function Ped:setAnimation(dict, name, flag)
    self.data.animDict = dict
    self.data.animName = name
    self.data.animFlag = flag

    if self.data.animDict and self.data.animName and self.data.animFlag and DoesEntityExist(self.pedHandle) then
        local tries, failed = 0, false

        RequestAnimDict(self.data.animDict)
        while not HasAnimDictLoaded(self.data.animDict) and not failed do
            tries = tries + 1

            if tries > 100 then
                failed = true
                _G.APIShared.Helpers.Logger:error("Failed to load animDict. (PED)")
            end

            Citizen.Wait(50)
        end

        if not failed then
            TaskPlayAnim(
                self.pedHandle,
                self.data.animDict,
                self.data.animName,
                1.0,
                1.0,
                -1,
                tonumber(self.data.animFlag),
                1.0,
                false,
                false,
                false
            )
        end
    end
end

function Ped:destroy()
    if _G.APIClient.Managers.PedManager.peds[self.remoteId] then
        _G.APIClient.Managers.PedManager.peds[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onPedDestroyed", self)

    if DoesEntityExist(self.pedHandle) then
        DeleteEntity(self.pedHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed ped (%d, %s)", self.remoteId, self.data.model)
    )
end

return Ped

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
    _G.APIShared.EventHandler:TriggerEvent("onObjectCreated", self)

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

    _G.APIShared.EventHandler:TriggerEvent("onObjectStreamedIn", self)

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

    _G.APIShared.EventHandler:TriggerEvent("onObjectStreamedOut", self)

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

    _G.APIShared.EventHandler:TriggerEvent("onObjectVariableChange", self, key, value)
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

    _G.APIShared.EventHandler:TriggerEvent("onObjectDestroyed", self)

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

---@param eventName string
---@param cb fun(...)
function EventHandler:AddEvent(eventName, cb)
    if type(self.events[eventName]) ~= "table" then
        self.events[eventName] = {}
    end

    self.events[eventName][#self.events[eventName] + 1] = cb
end

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