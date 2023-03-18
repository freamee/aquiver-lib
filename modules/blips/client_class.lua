---@param remoteId number
---@param data IBlip
function Client.Classes.Blips(remoteId, data)
    ---@class ClientBlipClass
    ---@field data IBlip
    ---@field remoteId number
    ---@field blipHandle number
    local self = {}

    self.data = data
    self.remoteId = remoteId
    self.blipHandle = nil

    if Client.Managers.Blips.exists(self.remoteId) then
        Shared.Utils.Error(string.format("Blip already exists. (%d)", self.remoteId))
        return
    end

    self.__init__ = function()
        -- Creating the blip here.
        local blip = AddBlipForCoord(self.getVector3Position())
        SetBlipSprite(blip, self.data.sprite)
        SetBlipDisplay(blip, self.data.display)
        SetBlipScale(blip, self.data.scale)
        SetBlipAlpha(blip, self.data.alpha)
        SetBlipAsShortRange(blip, self.data.shortRange)
        SetBlipColour(blip, self.data.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(self.data.name)
        EndTextCommandSetBlipName(blip)

        self.blipHandle = blip
    end

    self.getVector3Position = function()
        return vector3(self.data.x, self.data.y, self.data.z)
    end
    
    self.destroy = function()
        if Client.Managers.Blips.exists(self.remoteId) then
            Client.Managers.Blips.Entities[self.remoteId] = nil
        end

        if DoesBlipExist(self.blipHandle) then
            RemoveBlip(self.blipHandle)
        end

        TriggerEvent("onBlipDestroyed", self)

        Shared.Utils.Debug(string.format("Removed blip (%d)", self.remoteId))
    end

    self.__init__()

    Client.Managers.Blips.Entities[self.remoteId] = self

    Shared.Utils.Debug(string.format("Created new blip (%d)", self.remoteId))

    return self
end