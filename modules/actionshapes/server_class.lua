local remoteIdCounter = 1

---@class IActionShape
---@field x number
---@field y number
---@field z number
---@field color { r:number; g:number; b:number; a:number; }
---@field sprite number
---@field range number
---@field dimension number
---@field variables table
---@field resource? string

---@param data IActionShape
function Server.Classes.Actionshapes(data)
    ---@class ServerActionshapeClass
    ---@field remoteId number
    local self = {}

    self.data = data
    self.data.resource = Shared.Utils:GetResourceName()
    self.remoteId = remoteIdCounter

    remoteIdCounter += 1

    if Server.Managers.Actionshapes:exists(self.remoteId) then
        Shared.Utils:Error(string.format("Actionshape already exists. (%d, %s)", self.remoteId))
        return
    end

    self.__init__ = function()
        self.data.display = type(self.data.display) == "number" and self.data.display or 4
        self.data.shortRange = type(self.data.shortRange) == "boolean" and self.data.shortRange or true
        self.data.scale = type(self.data.scale) == "number" and self.data.scale or 1.0
        self.data.alpha = type(self.data.alpha) == "number" and self.data.alpha or 255
    end

    self.destroy = function()
        if Server.Managers.Actionshapes:exists(self.remoteId) then
            Server.Managers.Actionshapes.Entities[self.remoteId] = nil
        end

        TriggerEvent("onActionshapeDestroyed", self)
        TriggerClientEvent("AquiverLib:Actionshape:Destroy", -1, self.remoteId)

        Shared.Utils:Debug(string.format("Removed actionshape (%d)", self.remoteId))
    end

    self.__init__()

    Server.Managers.Actionshapes.Entities[self.remoteId] = self

    TriggerClientEvent("AquiverLib:Actionshape:Create", -1, self.remoteId, self.data)

    TriggerEvent("onActionshapeCreated", self)

    Shared.Utils:Debug(string.format("Created new actionshape (%d)", self.remoteId))

    return self
end