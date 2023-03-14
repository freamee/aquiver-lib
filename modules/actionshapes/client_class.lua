---@param remoteId number
---@param data IActionShape
function Client.Classes.Actionshape(remoteId, data)
    ---@class ClientActionshapeClass
    ---@field data IActionShape
    ---@field remoteId number
    ---@field isStreamed boolean
    ---@field isEntered boolean
    local self = {}

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.isEntered = false

    if Client.Managers.Actionshapes:exists(self.remoteId) then
        Shared.Utils:Error(string.format("Actionshape already exists. (%d)", self.remoteId))
        return
    end

    self.getVector3Position = function()
        return vector3(self.data.x, self.data.y, self.data.z)
    end

    ---@param vec3 vector3
    self.dist = function(vec3)
        return #(self:getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
    end

    self.onEnter = function()
        if self.isEntered then return end

        self.isEntered = true

        TriggerEvent("onActionshapeEnter", self)
        TriggerServerEvent("onActionshapeEnter", self.remoteId)
    end

    self.onLeave = function()
        if not self.isEntered then return end

        self.isEntered = false

        TriggerEvent("onActionshapeLeave", self)
        TriggerServerEvent("onActionshapeLeave", self.remoteId)
    end  
  
    self.addStream = function()
        if self.isStreamed then return end

        self.isStreamed = true

        if not Client.Managers.Actionshapes.Streamed[self.remoteId] then
            Client.Managers.Actionshapes.Streamed[self.remoteId] = self
        end
    
        Shared.Utils:Debug(string.format("Actionshape streamed in (%d)", self.remoteId))
    end

    self.removeStream = function()
        if not self.isStreamed then return end

        self.isStreamed = false

        if Client.Managers.Actionshapes.Streamed[self.remoteId] then
            Client.Managers.Actionshapes.Streamed[self.remoteId] = nil
        end
    
        Shared.Utils:Debug(string.format("Actionshape streamed out (%d)", self.remoteId))
    end
    
    self.destroy = function()
        if Client.Managers.Blips:exists(self.remoteId) then
            Client.Managers.Blips.Entities[self.remoteId] = nil
        end

        TriggerEvent("onActionshapeDestroyed", self)

        Shared.Utils:Debug(string.format("Removed actionshape (%d)", self.remoteId))
    end

    Client.Managers.Actionshapes.Entities[self.remoteId] = self

    Shared.Utils:Debug(string.format("Created new actionshape (%d)", self.remoteId))

    return self
end