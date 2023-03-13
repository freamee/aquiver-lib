local remoteIdCounter = 1

---@class ISqlObject
---@field id? number
---@field model string
---@field x number
---@field y number
---@field z number
---@field rx number
---@field ry number
---@field rz number
---@field variables table
---@field dimension number

---@param data ISqlObject
function Server.Classes.Objects(data)
    ---@class ServerObjectClass
    ---@field data ISqlObject
    ---@field remoteId number
    local self = {}

    self.data = data
    self.remoteId = remoteIdCounter

    remoteIdCounter += 1

    if Server.Managers.Objects:exists(self.remoteId) then
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

    self.getVar = function(key)
        return type(self.data.variables[key]) ~= "nil" and self.data.variables[key] or nil
    end

    self.setVar = function(key, value)
        if self.data.variables[key] == value then return end

        self.data.variables[key] = value

        TriggerClientEvent("AquiverLib:Object:Update:VariableKey",
            -1,
            self.remoteId,
            key,
            self.data.variables[key]
        )

        TriggerEvent("onObjectVariableChange", self, key, value)
    end

    ---@param vec3 vector3
    self.setPosition = function(vec3)
        if self.data.x == vec3.x and self.data.y == vec3.y and self.data.z == vec3.z then return end

        self.data.x = vec3.x
        self.data.y = vec3.y
        self.data.z = vec3.z

        TriggerClientEvent("AquiverLib:Object:Update:Position",
            -1,
            self.remoteId,
            self.data.x,
            self.data.y,
            self.data.z
        )
    end

    ---@param vec3 vector3
    self.setRotation = function(vec3)
        if self.data.rx == vec3.x and self.data.ry == vec3.y and self.data.rz == vec3.z then return end

        self.data.rx = vec3.x
        self.data.ry = vec3.y
        self.data.rz = vec3.z

        TriggerClientEvent("AquiverLib:Object:Update:Rotation",
            -1,
            self.remoteId,
            self.data.rx,
            self.data.ry,
            self.data.rz
        )
    end

    ---@param newModel string
    self.setModel = function(newModel)
        if self.data.model == newModel then return end

        self.data.model = newModel

        TriggerClientEvent("AquiverLib:Object:Update:Model",
            -1,
            self.remoteId,
            self.data.model
        )
    end

    self.destroy = function()
        if Server.Managers.Objects:exists(self.remoteId) then
            Server.Managers.Objects.Entities[self.remoteId] = nil
        end

        TriggerEvent("onObjectDestroyed", self)
        TriggerClientEvent("AquiverLib:Object:Destroy", self.remoteId)

        Shared.Utils:Debug(string.format("Removed object (%d, %s)", self.remoteId, self.data.model))
    end

    Server.Managers.Objects.Entities[self.remoteId] = self

    TriggerClientEvent("AquiverLib:Object:Create", -1, self.remoteId, self.data)

    TriggerEvent("onObjectCreated", self)

    Shared.Utils:Debug(string.format("Created new object (%d, %s)", self.remoteId, self.data.model))

    return self
end