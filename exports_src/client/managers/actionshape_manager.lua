local Actionshape = require("client.gameobjects.actionshape.actionshape")

---@class Client_ActionshapeManager
---@field shapes table<number, API_Client_ActionshapeBase>
local ActionshapeManager = {}
ActionshapeManager.__index = ActionshapeManager

ActionshapeManager.new = function()
    local self = setmetatable({}, ActionshapeManager)

    self.shapes = {}

    return self
end

---@param remoteId number
---@param data IActionShape
function ActionshapeManager:createActionshape(remoteId, data)
    if self.shapes[remoteId] then
        return self.shapes[remoteId]
    end

    self.shapes[remoteId] = Actionshape.new(remoteId, data)

    return self.shapes[remoteId]
end

function ActionshapeManager:getActionshape(remoteId)
    return self.shapes[remoteId]
end

---@param vec3 vector3
function ActionshapeManager:getNearestEnteredActionShape(vec3)
    local closest = nil
    local rangeMeter = nil

    if type(vec3) == "vector3" then
        for k, v in pairs(self.shapes) do
            local dist = v:dist(vec3)
            if (rangeMeter == nil or dist < rangeMeter) and dist < v.data.range then
                rangeMeter = dist
                closest = v
            end
        end
    end

    return closest
end

return ActionshapeManager
