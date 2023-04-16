---@class Client_LocalPlayer
---@field dimension number
---@field cache { playerId:number; playerPed:number; playerServerId:number; playerCoords:vector3; playerHeading:number; }
---@field cacherInterval Interval_Class
local Local = {}
Local.__index = Local

Local.new = function()
    local self = setmetatable({}, Local)

    self.dimension = 0
    self.cache = {}

    self:cacheNow()

    self.cacherInterval = _G.APIShared.Helpers.Interval.new(1000, function()
        self:cacheNow()
    end)
    self.cacherInterval:start()

    AddStateBagChangeHandler("dimension", nil, function(bagName, key, value)
        local ply = GetPlayerFromStateBagName(bagName)
        if ply == 0 or ply ~= self.cache.playerId then return end

        self.dimension = value
    end)

    AddStateBagChangeHandler("attachments", nil, function(bagName, key, value)
        local ply = GetPlayerFromStateBagName(bagName)
        if ply == 0 then return end

        print(key, value)
    end)

    RegisterNetEvent("aquiver-lib:sendNuiMessage", function(jsonContent)
        SendNUIMessage(jsonContent)
    end)

    return self
end

function Local:cacheNow()
    self.cache.playerId = PlayerId()
    self.cache.playerPed = PlayerPedId()
    self.cache.playerServerId = GetPlayerServerId(self.cache.playerId)
    self.cache.playerCoords = GetEntityCoords(self.cache.playerPed)
    self.cache.playerHeading = GetEntityHeading(self.cache.playerPed)
end

function Local:sendApiMessage(jsonContent)
    TriggerEvent("aquiver-lib:sendApiMessage", jsonContent)
end

function Local:sendNuiMessage(jsonContent)
    TriggerEvent("aquiver-lib:sendNuiMessage", jsonContent)
end

return Local
