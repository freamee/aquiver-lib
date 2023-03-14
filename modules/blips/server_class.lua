local remoteIdCounter = 1

---@class IBlip
---@field x number
---@field y number
---@field z number
---@field alpha number
---@field color number
---@field sprite number
---@field name string
---@field display? number
---@field shortRange? boolean
---@field scale? number
---@field resource? string

---@param data IBlip
function Server.Classes.Blips(data)
    ---@class ServerBlipClass
    ---@field remoteId number
    local self = {}

    self.data = data
    self.data.resource = Shared.Utils:GetResourceName()
    self.remoteId = remoteIdCounter

    remoteIdCounter += 1

    if Server.Managers.Blips:exists(self.remoteId) then
        Shared.Utils:Error(string.format("Blip already exists. (%d, %s)", self.remoteId))
        return
    end

    self.__init__ = function()
        self.data.display = type(self.data.display) == "number" and self.data.display or 4
        self.data.shortRange = type(self.data.shortRange) == "boolean" and self.data.shortRange or true
        self.data.scale = type(self.data.scale) == "number" and self.data.scale or 1.0
        self.data.alpha = type(self.data.alpha) == "number" and self.data.alpha or 255
    end

    self.destroy = function()
        if Server.Managers.Blips:exists(self.remoteId) then
            Server.Managers.Blips.Entities[self.remoteId] = nil
        end

        TriggerEvent("onBlipDestroyed", self)
        TriggerClientEvent("AquiverLib:Blip:Destroy", -1, self.remoteId)

        Shared.Utils:Debug(string.format("Removed blip (%d)", self.remoteId))
    end

    ---@param colorId number
    self.setColor = function(colorId)
        self.data.color = colorId
        TriggerClientEvent("AquiverLib:Blip:Update:Color", -1, self.remoteId, colorId)
    end

    self.setPosition = function(x, y, z)
        self.data.x = x
        self.data.y = y
        self.data.z = z
        TriggerClientEvent("AquiverLib:Blip:Update:Position", -1, self.remoteId, x, y, z)
    end

    self.__init__()

    Server.Managers.Blips.Entities[self.remoteId] = self

    TriggerClientEvent("AquiverLib:Blip:Create", -1, self.remoteId, self.data)

    TriggerEvent("onBlipCreated", self)

    Shared.Utils:Debug(string.format("Created new blip (%d)", self.remoteId))

    return self
end