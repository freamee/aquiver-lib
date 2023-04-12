local Ped = require("client.gameobjects.ped.ped")

---@class Client_PedManager
---@field peds table<number, API_Client_PedBase>
local PedManager = {}
PedManager.__index = PedManager

PedManager.new = function()
    local self = setmetatable({}, PedManager)

    self.peds = {}

    return self
end

---@param remoteId number
---@param data IPed
function PedManager:createPed(remoteId, data)
    if self.peds[remoteId] then
        return self.peds[remoteId]
    end

    self.peds[remoteId] = Ped.new(remoteId, data)

    return self.peds[remoteId]
end

function PedManager:getPed(remoteId)
    return self.peds[remoteId]
end

return PedManager
