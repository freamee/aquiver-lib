Server = {}
Server.Classes = {}
Server.Managers = {}

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
    local aPlayer <const> = Server.Managers.Players:get(source)
    if not aPlayer then return end

    Shared.Utils:Debug(aPlayer, true)

    aPlayer:destroy()
end)

AddEventHandler("playerJoining", function()
    local source <const> = source
    Server.Classes.Players(source)
end)