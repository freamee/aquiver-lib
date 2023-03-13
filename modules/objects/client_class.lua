---@param remoteId number
---@param data ISqlObject
function Client.Classes.Objects(remoteId, data)
    ---@class ClientObjectClass
    ---@field data ISqlObject
    ---@field remoteId number
    ---@field isStreamed boolean
    ---@field objectHandle number
    local self = {}

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.objectHandle = nil

    if Client.Managers.Objects:exists(self.remoteId) then
        Shared.Utils:Error(string.format("Object already exists. (%d, %s)", self.remoteId, self.data.model))
        return
    end

    self.getVector3Position = function()
        return vector3(self.data.x, self.data.y, self.data.z)
    end
    
    self.getVector3Rotation = function()
        return vector3(self.data.rx, self.data.ry, self.data.rz)
    end

    ---@param vec3 vector3
    self.dist = function(vec3)
        return #(self.getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
    end

    self.addStream = function()
        if self.isStreamed then return end

        self.isStreamed = true

        local modelHash = GetHashKey(self.data.model)
        if not IsModelValid(modelHash) then return end

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(100)
        end

        local obj = CreateObjectNoOffset(modelHash, self.getVector3Position(), false, false, false)
        SetEntityRotation(obj, self.getVector3Rotation(), 2, false)
        FreezeEntityPosition(obj, true)
        self.objectHandle = obj

        TriggerEvent("onObjectStreamedIn", self)

        Shared.Utils:Debug(string.format("Object streamed in (%d, %s)", self.remoteId, self.data.model))
    end

    self.removeStream = function()
        if not self.isStreamed then return end

        if DoesEntityExist(self.objectHandle) then
            DeleteEntity(self.objectHandle)
        end

        self.isStreamed = false

        TriggerEvent("onObjectStreamedOut", self)

        Shared.Utils:Debug(string.format("Object streamed out (%d, %s)", self.remoteId, self.data.model))
    end

    self.destroy = function()
        if Client.Managers.Objects:exists(self.remoteId) then
            Client.Managers.Objects.Entities[self.remoteId] = nil
        end

        if DoesEntityExist(self.objectHandle) then
            DeleteEntity(self.objectHandle)
        end

        TriggerEvent("onObjectDestroyed", self)

        Shared.Utils:Debug(string.format("Removed object (%d, %s)", self.remoteId, self.data.model))
    end

    Client.Managers.Objects.Entities[self.remoteId] = self

    Shared.Utils:Debug(string.format("Created new object (%d, %s)", self.remoteId, self.data.model))

    return self
end