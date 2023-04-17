---@class Client_LocalPlayer
---@field dimension number
---@field cache { playerId:number; playerPed:number; playerServerId:number; playerCoords:vector3; playerHeading:number; }
---@field cacherInterval Interval_Class
---@field private disableMovementInterval Interval_Class
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

    AddStateBagChangeHandler("playerDimension", nil, function(bagName, key, value)
        local ply = GetPlayerFromStateBagName(bagName)
        if ply == 0 or ply ~= PlayerId() then return end

        self.dimension = value
    end)

    RegisterNetEvent(_G.APIShared.resource .. ":sendNuiMessage", function(jsonContent)
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
    TriggerEvent(_G.APIShared.resource .. ":sendNuiMessage", jsonContent)
end

---@param dict string
---@param name string
---@param flag number
function Local:playAnimation(dict, name, flag)
    local playerPed = PlayerPedId()
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, dict, name, 4.0, 4.0, -1, tonumber(flag), 1.0, false, false, false)
end

function Local:stopAnimation()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end

---@param state boolean
function Local:disableMovement(state)
    if not self.disableMovementInterval then
        self.disableMovementInterval = _G.APIShared.Helpers.Interval.new(0, function()
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end)
    end

    if state then
        self.disableMovementInterval:start()
    else
        self.disableMovementInterval:stop()
    end
end

---@param state boolean
function Local:freeze(state)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, state)
end

RegisterNetEvent(_G.APIShared.resource .. "player:playAnimation", function(dict, name, flag)
    _G.APIClient.LocalPlayer:playAnimation(dict, name, flag)
end)
RegisterNetEvent(_G.APIShared.resource .. "player:stopAnimation", function()
    _G.APIClient.LocalPlayer:stopAnimation()
end)
RegisterNetEvent(_G.APIShared.resource .. "player:disableMovement", function(state)
    _G.APIClient.LocalPlayer:disableMovement(state)
end)
RegisterNetEvent(_G.APIShared.resource .. "player:freeze", function(state)
    _G.APIClient.LocalPlayer:freeze(state)
end)

return Local
