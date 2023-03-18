---@class AquiverLibServer
Server = {}
Server.Classes = {}
Server.Managers = {}

if GetResourceState("es_extended") ~= "missing" then
    Shared.Utils.Info("ESX framework recognized.")
    Server.ESX = exports['es_extended']:getSharedObject()
else
    Shared.Utils.Info("Standalone framework recognized.")
end

exports("getServer", function()
    return Server
end)

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local onlinePlayers <const> = GetPlayers()
    for i = 1, #onlinePlayers do
        Server.Classes.Players(onlinePlayers[i])
    end
end)

AddEventHandler("playerDropped", function()
    local source <const> = source
    local aPlayer <const> = Server.Managers.Players.get(source)
    if not aPlayer then return end

    aPlayer:destroy()
end)

AddEventHandler("playerJoining", function()
    local source <const> = source
    Server.Classes.Players(source)
end)