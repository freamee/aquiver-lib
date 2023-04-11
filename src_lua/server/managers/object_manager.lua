local Object = require("server.gameobjects.object.object")

---@class Server_ObjectManager
---@field objects table<number, API_Server_ObjectBase>
---@field remoteIdCounter number
local ObjectManager = {}
ObjectManager.__index = ObjectManager

ObjectManager.new = function()
    local self = setmetatable({}, ObjectManager)

    self.objects = {}
    self.remoteIdCounter = 0

    return self
end

---@param data ISQLObject
function ObjectManager:createObject(data)
    local remoteId = self:getNextRemoteId()

    self.objects[remoteId] = Object.new(remoteId, data)

    return self.objects[remoteId]
end

function ObjectManager:getNextRemoteId()
    self.remoteIdCounter = self.remoteIdCounter + 1
    return self.remoteIdCounter
end

function ObjectManager:getObject(remoteId)
    return self.objects[remoteId]
end

---@param data ISQLObject
---@async
function ObjectManager:insertSQL(data)
    local insertId = exports["oxmysql"]:insert_async(
        "INSERT INTO avp_lib_objects (model, x, y, z, rx, ry, rz, dimension, resource, variables) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        {
            data.model,
            data.x,
            data.y,
            data.z,
            type(data.rx) == "number" and data.rx or 0.0,
            type(data.ry) == "number" and data.ry or 0.0,
            type(data.rz) == "number" and data.rz or 0.0,
            type(data.dimension) == "number" and data.dimension or 0,
            _G.APIServer.resource,
            type(data.variables) == "table" and json.encode(data.variables) or json.encode({})
        }
    )
    if type(insertId) == "number" then
        local dataResponse = exports["oxmysql"]:single_async(
            "SELECT * FROM avp_lib_objects WHERE id = ?",
            { insertId }
        )
        if dataResponse then
            return self:createObject(dataResponse)
        end
    end
end

function ObjectManager:loadObjectsFromSql()
    exports["oxmysql"]:query("SELECT * FROM avp_lib_objects WHERE resource = ?", {
        _G.APIServer.resource
    }, function(responseData)
        if responseData and type(responseData) == "table" then
            for i = 1, #responseData do
                self:createObject(responseData[i])
            end
        end
    end)
end

---@param vec3 vector3
---@param model string | nil
---@param range number
---@param dimension number
function ObjectManager:getObjectsInRange(vec3, model, range, dimension)
    ---@type API_Server_ObjectBase[]
    local collectedObjects = {}

    if type(vec3) == "vector3" then
        for k, v in pairs(self.objects) do
            if v.data.dimension == dimension then
                if model then
                    if v.data.model == model then
                        local dist = v:dist(vec3)
                        if dist < range then
                            collectedObjects[#collectedObjects + 1] = v
                        end
                    end
                else
                    local dist = v:dist(vec3)
                    if dist < range then
                        collectedObjects[#collectedObjects + 1] = v
                    end
                end
            end
        end
    end

    return collectedObjects
end

---@param vec3 vector3
---@param model string | string[] | nil
---@param range number
---@param dimension number
---@return API_Server_ObjectBase | nil
function ObjectManager:getNearestObject(vec3, model, range, dimension)
    local rangeMeter = range
    local closest = nil

    if type(vec3) == "vector3" then
        for k, v in pairs(self.objects) do
            if v.data.dimension == dimension then
                if model then
                    if type(model) == "table" then
                        for i = 1, #model do
                            if v.data.model == model[i] then
                                local dist = v:dist(vec3)
                                if dist < rangeMeter then
                                    rangeMeter = dist
                                    closest = v
                                end
                            end
                        end
                    else
                        if v.data.model == model then
                            local dist = v:dist(vec3)
                            if dist < rangeMeter then
                                rangeMeter = dist
                                closest = v
                            end
                        end
                    end
                else
                    local dist = v:dist(vec3)
                    if dist < rangeMeter then
                        rangeMeter = dist
                        closest = v
                    end
                end
            end
        end
    end

    return closest
end

return ObjectManager
