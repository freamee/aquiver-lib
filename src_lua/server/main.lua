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

    _G.APIServer.Managers.ObjectManager:createObject({
        dimension = 0,
        model = "prop_barrel_02a",
        rx = 0,
        ry = 0,
        rz = 0,
        variables = {},
        x = 2440,
        y = 3770,
        z = 41
    })

    _G.APIServer.Managers.PedManager:createPed({
        dimension = 0,
        heading = 0,
        model = "a_m_y_beach_01",
        name = "Steph Curry",
        pos = vector(2430, 3770, 41),
        questionMark = true,
        scenario = "WORLD_HUMAN_BINOCULARS"
    })

    _G.APIServer.Managers.ActionshapeManager:createActionshape({
        dimension = 0,
        pos = vector3(2430, 3770, 41),
        range = 5.0,
        sprite = 1,
        variables = {},
        color = { r = 0, g = 0, b = 200, a = 200 },
        streamDistance = 10.0
    })
end)
