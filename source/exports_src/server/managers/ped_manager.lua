local Ped = require("server.gameobjects.ped.ped")

---@class PedManager
---@field peds table<number, API_Server_PedBase>
---@field remoteIdCounter number
local PedManager = {}
PedManager.__index = PedManager

PedManager.new = function()
    local self = setmetatable({}, PedManager)

    self.peds = {}
    self.remoteIdCounter = 0

    return self
end

---@param data IPed
function PedManager:createPed(data)
    local remoteId = self:getNextRemoteId()

    self.peds[remoteId] = Ped.new(remoteId, data)

    return self.peds[remoteId]
end

function PedManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function PedManager:getPed(remoteId)
    return self.peds[remoteId]
end

return PedManager
