local Actionshape = require("server.gameobjects.actionshape.actionshape")

---@class ActionshapeManager
---@field shapes table<number, API_Server_ActionshapeBase>
---@field remoteIdCounter number
local ActionshapeManager = {}
ActionshapeManager.__index = ActionshapeManager

ActionshapeManager.new = function()
    local self = setmetatable({}, ActionshapeManager)

    self.shapes = {}
    self.remoteIdCounter = 0

    return self
end

---@param data IActionShape
function ActionshapeManager:createActionshape(data)
    local remoteId = self:getNextRemoteId()

    self.shapes[remoteId] = Actionshape.new(remoteId, data)

    return self.shapes[remoteId]
end

function ActionshapeManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function ActionshapeManager:getActionshape(remoteId)
    return self.shapes[remoteId]
end

return ActionshapeManager
