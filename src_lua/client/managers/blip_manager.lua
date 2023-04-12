local Blip = require("client.gameobjects.blip.blip")

---@class Client_BlipManager
---@field blips table<number, API_Client_BlipBase>
local BlipManager = {}
BlipManager.__index = BlipManager

BlipManager.new = function()
    local self = setmetatable({}, BlipManager)

    self.blips = {}

    return self
end

---@param remoteId number
---@param data IBlip
function BlipManager:createBlip(remoteId, data)
    if self.blips[remoteId] then
        return self.blips[remoteId]
    end

    self.blips[remoteId] = Blip.new(remoteId, data)

    return self.blips[remoteId]
end

function BlipManager:getBlip(remoteId)
    return self.blips[remoteId]
end

return BlipManager
