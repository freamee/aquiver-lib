---@class API_Client_ObjectBase
---@field data ISQLObject
---@field remoteId number
---@field isStreamed boolean
---@field objectHandle number
local Object = {}
Object.__index = Object

---@param remoteId number
---@param data ISQLObject
Object.new = function(remoteId, data)
    local self = setmetatable({}, Object)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.objectHandle = nil

    self:__init__()

    return self
end

function Object:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onObjectCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    local modelHash = GetHashKey(self.data.model)
    if not IsModelValid(modelHash) then return end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local obj = CreateObjectNoOffset(modelHash, self:getVector3Position(), false, false, false)
    SetEntityRotation(obj, self:getVector3Rotation(), 2, false)
    FreezeEntityPosition(obj, true)

    self.objectHandle = obj

    _G.APIShared.EventHandler:TriggerEvent("onObjectStreamedIn", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Object streamed in (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:removeStream()
    if not self.isStreamed then return end

    if DoesEntityExist(self.objectHandle) then
        DeleteEntity(self.objectHandle)
    end

    self.isStreamed = false

    _G.APIShared.EventHandler:TriggerEvent("onObjectStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Object streamed out (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:getVector3Position()
    return vector3(self.data.x, self.data.y, self.data.z)
end

function Object:getVector3Rotation()
    return vector3(self.data.rx, self.data.ry, self.data.rz)
end

---@param vec3 vector3
function Object:dist(vec3)
    return #(self:getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
end

function Object:setVar(key, value)
    if self.data.variables[key] == value then return end

    self.data.variables[key] = value

    _G.APIShared.EventHandler:TriggerEvent("onObjectVariableChange", self, key, value)
end

---@param vec3 vector3
function Object:setPosition(vec3)
    if self.data.x == vec3.x and self.data.y == vec3.y and self.data.z == vec3.z then return end

    self.data.x = vec3.x
    self.data.y = vec3.y
    self.data.z = vec3.z

    if DoesEntityExist(self.objectHandle) then
        SetEntityCoords(self.objectHandle, self:getVector3Position(), false, false, false, false)
    end
end

---@param alpha number
function Object:setAlpha(alpha)
    if self.data.alpha == alpha then return end

    self.data.alpha = alpha

    if DoesEntityExist(self.objectHandle) then
        SetEntityAlpha(self.objectHandle, alpha, false)
    end
end

---@param vec3 vector3
function Object:setRotation(vec3)
    if self.data.rx == vec3.x and self.data.ry == vec3.y and self.data.rz == vec3.z then return end

    self.data.rx = vec3.x
    self.data.ry = vec3.y
    self.data.rz = vec3.z

    if DoesEntityExist(self.objectHandle) then
        SetEntityRotation(self.objectHandle, self:getVector3Rotation(), 2, false)
    end
end

---@param model string
function Object:setModel(model)
    if self.data.model == model then return end

    self.data.model = model

    if self.isStreamed then
        self:removeStream()
        self:addStream()
    end
end

function Object:destroy()
    if _G.APIClient.Managers.ObjectManager.objects[self.remoteId] then
        _G.APIClient.Managers.ObjectManager.objects[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onObjectDestroyed", self)

    if DoesEntityExist(self.objectHandle) then
        DeleteEntity(self.objectHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed object (%d, %s)", self.remoteId, self.data.model)
    )
end

return Object
