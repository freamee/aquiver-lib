local Actionshape = require("server.gameobjects.actionshape.actionshape")

---@class ActionshapeManager
---@field actionshapes table<number, API_Server_ActionshapeBase>
---@field remoteIdCounter number
local ActionshapeManager = {}
ActionshapeManager.__index = ActionshapeManager

ActionshapeManager.new = function()
    local self = setmetatable({}, ActionshapeManager)

    self.actionshapes = {}
    self.remoteIdCounter = 0

    return self
end

---@param data IActionShape
function ActionshapeManager:createActionshape(data)
    local remoteId = self:getNextRemoteId()

    self.actionshapes[remoteId] = Actionshape.new(remoteId, data)

    return self.actionshapes[remoteId]
end

function ActionshapeManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function ActionshapeManager:getActionshape(remoteId)
    return self.actionshapes[remoteId]
end

return ActionshapeManager
