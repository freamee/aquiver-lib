local Module <const> = {}
Module.cache = {
    playerId = nil,
    playerPed = nil,
    playerServerId = nil,
    playerCoords = nil,
    playerHeading = nil
}

Client.LocalPlayer = Module

function Module:cacheNow()
    self.cache.playerId = PlayerId()
    self.cache.playerPed = PlayerPedId()
    self.cache.playerServerId = GetPlayerServerId(self.cache.playerId)
    self.cache.playerCoords = GetEntityCoords(self.cache.playerPed)
    self.cache.playerHeading = GetEntityHeading(self.cache.playerPed)
end

Module:cacheNow()

Citizen.CreateThread(function()
    while true do
        Module:cacheNow()
        Citizen.Wait(1000)
    end
end)