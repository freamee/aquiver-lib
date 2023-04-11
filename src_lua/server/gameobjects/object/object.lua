---@class ISQLObject
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
---@field resource string

---@class API_Server_ObjectBase
---@field data ISQLObject
---@field remoteId number
local Object = {}
Object.__index = Object

---@param remoteId number
---@param data ISQLObject
Object.new = function(remoteId, data)
    local self = setmetatable({}, Object)

    self.data = data
    self.remoteId = remoteId

    TriggerEvent(_G.APIServer.resource .. "onObjectCreated", self)

    --     TriggerClientEvent("AquiverLib:Object:Create", -1, self.remoteId, self.data)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )

    return self
end

function Object:getVector3Position()
    return vector3(self.data.x, self.data.y, self.data.z)
end

function Object:getVector3Rotation()
    return vector3(self.data.rx, self.data.ry, self.data.rz)
end

---@param vec3 vector3
function Object:dist(vec3)
    return #(self:getVector3Position() - vectro3(vec3.x, vec3.y, vec3.z))
end

function Object:getVar(key)
    return self.data.variables[key]
end

function Object:setVar(key, value)
    if self.data.variables[key] == value then return end

    self.data.variables[key] = value

    --         TriggerClientEvent("AquiverLib:Object:Update:VariableKey",
    --             -1,
    --             self.remoteId,
    --             key,
    --             self.data.variables[key]
    --         )

    TriggerEvent(_G.APIServer.resource .. ":onObjectVariableChange", self, key, value)

    -- // TODO: Performance increase here with some timeout.
    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET variables = ? WHERE id = ?", {
            json.encode(self.data.variables),
            self.data.id
        })
    end
end

---@param vec3 vector3
function Object:setPosition(vec3)
    if self.data.x == vec3.x and self.data.y == vec3.y and self.data.z == vec3.z then return end

    self.data.x = vec3.x
    self.data.y = vec3.y
    self.data.z = vec3.z

    -- TriggerClientEvent("AquiverLib:Object:Update:Position",
    --     -1,
    --     self.remoteId,
    --     self.data.x,
    --     self.data.y,
    --     self.data.z
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET x = ?, y = ?, z = ? WHERE id = ?", {
            self.data.x,
            self.data.y,
            self.data.z,
            self.data.id
        })
    end
end

---@param vec3 vector3
function Object:setRotation(vec3)
    if self.data.rx == vec3.x and self.data.ry == vec3.y and self.data.rz == vec3.z then return end

    self.data.rx = vec3.x
    self.data.ry = vec3.y
    self.data.rz = vec3.z

    -- TriggerClientEvent("AquiverLib:Object:Update:Rotation",
    --     -1,
    --     self.remoteId,
    --     self.data.rx,
    --     self.data.ry,
    --     self.data.rz
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET rx = ?, ry = ?, rz = ? WHERE id = ?", {
            self.data.rx,
            self.data.ry,
            self.data.rz,
            self.data.id
        })
    end
end

---@param model string
function Object:setModel(model)
    if self.data.model == model then return end

    self.data.model = model

    -- TriggerClientEvent("AquiverLib:Object:Update:Model",
    --     -1,
    --     self.remoteId,
    --     self.data.model
    -- )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET model = ? WHERE id = ?", {
            self.data.model,
            self.data.id
        })
    end
end

function Object:destroy()
    --         if Server.Managers.Objects.exists(self.remoteId) then
    --             Server.Managers.Objects.Entities[self.remoteId] = nil
    --         end
    TriggerEvent(_G.APIServer.resource .. "onObjectDestroyed", self)
    --         TriggerClientEvent("AquiverLib:Object:Destroy", self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed object (%d, %s)", self.remoteId, self.data.model)
    )
end

return Object
