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

    self:__init__()

    return self
end

---@private
function Object:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onObjectCreated", self)

    -- Create for everyone.
    self:createForPlayer(-1)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new object (%d, %s)", self.remoteId, self.data.model)
    )
end

function Object:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "objects:create", source, self.remoteId, self.data)
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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:variablekey",
        -1,
        self.remoteId,
        key,
        value
    )

    _G.APIShared.EventHandler:TriggerEvent("onObjectVariableChange", self, key, value)

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:position",
        -1,
        self.remoteId,
        self.data.x,
        self.data.y,
        self.data.z
    )

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:rotation",
        -1,
        self.remoteId,
        self.data.rx,
        self.data.ry,
        self.data.rz
    )

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

    TriggerClientEvent(
        _G.APIShared.resource .. "objects:set:model",
        -1,
        self.remoteId,
        self.data.model
    )

    if type(self.data.id) == "number" then
        exports["oxmysql"]:prepare("UPDATE avp_lib_objects SET model = ? WHERE id = ?", {
            self.data.model,
            self.data.id
        })
    end
end

function Object:destroy()
    if _G.APIServer.Managers.ObjectManager.objects[self.remoteId] then
        _G.APIServer.Managers.ObjectManager.objects[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onObjectDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "objects:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed object (%d, %s)", self.remoteId, self.data.model)
    )
end

return Object
