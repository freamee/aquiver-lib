local Module <const> = {}
---@type { [number]: ServerObjectClass }
Module.Entities = {}

Server.Managers.Objects = Module

---@param remoteId number
function Module.exists(remoteId)
    return Module.Entities[remoteId] and true or false
end

---@param remoteId number
function Module.atRemoteId(remoteId)
    return Module.Entities[remoteId] or nil
end

---@param vec3 vector3
---@param model? string | nil
---@param range number
function Module.getObjectsInRange(vec3, model, range)
    local collectedObjects = {}

    if type(vec3) ~= "vector3" then return end

    for k, v in pairs(Module.Entities) do
        if model then
            if v.data.model == model then
                local dist = v.dist(vec3)
                if dist < range then
                    collectedObjects[#collectedObjects + 1] = v
                end
            end
        else
            local dist = v.dist(vec3)
            if dist < range then
                collectedObjects[#collectedObjects + 1] = v
            end
        end
    end

    return collectedObjects
end

---@param vec3 vector3
---@param model? string | string[] | nil
---@param range number
---@param dimension number
function Module.getNearestObject(vec3, model, range, dimension)
    local rangeMeter = range
    local closest

    if type(vec3) ~= "vector3" then return end

    for k, v in pairs(Module.Entities) do
        if v.data.dimension == dimension then
            if model then
                if type(model) == "table" then
                    for i = 1, #model do
                        if v.data.model == model[i] then
                            local dist = v.dist(vec3)
                            if dist < rangeMeter then
                                rangeMeter = dist
                                closest = v
                            end
                        end
                    end
                elseif type(model) == "string" then
                    if v.data.model == model then
                        local dist = v.dist(vec3)
                        if dist < rangeMeter then
                            rangeMeter = dist
                            closest = v
                        end
                    end
                end
            else
                local dist = v.dist(vec3)
                if dist < rangeMeter then
                    rangeMeter = dist
                    closest = v
                end
            end
        end
    end

    return closest
end

---@param data ISqlObject
function Module.insertSQL(data)
    local insertId = exports["oxmysql"]:insert_async([[
        INSERT INTO avp_lib_objects (model, x, y, z, rx, ry, rz, dimension, resource, variables) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]],
    {
        data.model,
        data.x,
        data.y,
        data.y,
        type(data.rx) == "number" and data.rx or 0.0,
        type(data.ry) == "number" and data.ry or 0.0,
        type(data.rz) == "number" and data.rz or 0.0,
        type(data.dimension) == "number" and data.dimension or 0,
        Shared.Utils:GetResourceName(),
        type(data.variables) == "table" and json.encode(data.variables) or json.encode({})
    })
    if type(insertId) == "number" then
        local dataResponse = exports["oxmysql"]:single_async(
            "SELECT * FROM avp_lib_objects WHERE id = ?",
            { insertId }
        )
        if dataResponse then
            Server.Classes.Objects(dataResponse)
        end
    end
end

function Module.loadObjectsFromSql()
    exports["oxmysql"]:query(
        "SELECT * FROM avp_lib_objects WHERE resource = ?",
        { Shared.Utils:GetResourceName() }
    ,
    function(response)
        if response and type(response) == "table" then
            for i = 1, #response, 1 do
                Server.Classes.Objects(response[i])
            end
        end
    end)
end