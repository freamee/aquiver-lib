local Blip = require("server.gameobjects.blip.blip")

---@class BlipManager
---@field blips table<number, API_Server_BlipBase>
---@field remoteIdCounter number
local BlipManager = {}
BlipManager.__index = BlipManager

BlipManager.new = function()
    local self = setmetatable({}, BlipManager)

    self.blips = {}
    self.remoteIdCounter = 1

    return self
end

---@param data IBlip
function BlipManager:createBlip(data)
    local remoteId = self:getNextRemoteId()

    self.blips[remoteId] = Blip.new(remoteId, data)

    return self.blips[remoteId]
end

function BlipManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function BlipManager:getBlip(remoteId)
    return self.blips[remoteId]
end

return BlipManager
