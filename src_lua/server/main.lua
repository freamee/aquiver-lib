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
    print("ESX framework recognized.")
    _G.APIServer.ESX = exports['es_extended']:getSharedObject()
else
    print("Standalone framework recognized.")
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
