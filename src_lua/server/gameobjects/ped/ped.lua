---@class IPed
---@field pos vector3
---@field heading number
---@field model string
---@field dimension number
---@field scenario? string
---@field animDict? string
---@field animName? string
---@field animFlag? number
---@field questionMark? boolean
---@field name? string

---@class API_Server_PedBase
---@field data IPed
---@field remoteId number
local Ped = {}
Ped.__index = Ped

---@param remoteId number
---@param data IPed
Ped.new = function(remoteId, data)
    local self = setmetatable({}, Ped)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

function Ped:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new ped (%d, %s)", self.remoteId, self.data.model)
    )

    TriggerEvent(_G.APIServer.resource .. ":onPedCreated", self)
end

function Ped:destroy()
    if _G.APIServer.Managers.PedManager.peds[self.remoteId] then
        _G.APIServer.Managers.PedManager.peds[self.remoteId] = nil
    end

    TriggerEvent(_G.APIServer.resource .. "onPedDestroyed", self)
    -- --         TriggerClientEvent("AquiverLib:Object:Destroy", self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed ped (%d, %s)", self.remoteId, self.data.model)
    )
end

return Ped
