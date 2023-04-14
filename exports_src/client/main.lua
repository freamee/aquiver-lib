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

-- Client player loading handler.
CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            _G.APIShared.EventHandler:TriggerEvent("PlayerLoaded")
            break
        end

        Citizen.Wait(1000)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    _G.APIShared.EventHandler:TriggerEvent("ScriptStopped")
end)

AddEventHandler("onResourceStart", function(resourceName)
    if _G.APIShared.resource ~= resourceName then return end

    _G.APIShared.EventHandler:TriggerEvent("ScriptStarted")
end)

RegisterNUICallback("menuExecuteCallback", function(d, cb)
    local index = d.index
    print(index)
    TriggerServerEvent("menuExecuteCallback", index)
    cb({})
end)
