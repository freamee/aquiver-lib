local Shared = require("shared.shared")

_G.APIShared = Shared

local Config = require("server.config")
local Managers = require("server.managers.managers")
local Helpers = require("server.helpers.helpers")

_G.APIServer = {}
_G.APIServer.Helpers = Helpers
_G.APIServer.Managers = Managers
_G.APIServer.CONFIG = Config
_G.APIServer.ESX = nil    -- Will be defined after, if its an ESX server.
_G.APIServer.QBCORE = nil -- Will be defined after, if its a QBCORE server.

-- Events needs to be loaded after the _G.APIServer initialized.
require("server.events.events")

if GetResourceState("qb-core") ~= "missing" then
    _G.APIShared.Helpers.Logger:info("QBCORE Framework recognized.")
    _G.APIServer.QBCORE = exports["qb-core"]:GetCoreObject()
end

if GetResourceState("es_extended") ~= "missing" then
    _G.APIShared.Helpers.Logger:info("ESX Framework recognized.")
    _G.APIServer.ESX = exports['es_extended']:getSharedObject()
end

if not (_G.APIServer.ESX and _G.APIServer.QBCORE) then
    _G.APIShared.Helpers.Logger:info("Standalone framework recognized.")
end

if _G.APIServer.ESX then
    AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
        _G.APIServer.Managers.PlayerManager:onPlayerConnect(playerId)
    end)
elseif _G.APIServer.QBCORE then
    AddEventHandler("QBCore:Server:PlayerLoaded", function(qPlayer)
        _G.APIServer.Managers.PlayerManager:onPlayerConnect(qPlayer.PlayerData.source)
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
