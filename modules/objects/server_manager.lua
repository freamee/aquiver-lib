local Module <const> = {}
---@type { [number]: ServerObjectClass }
Module.Entities = {}

Server.Managers.Objects = Module

---@param remoteId number
function Module:exists(remoteId)
    return self.Entities[remoteId] and true or false
end

---@param remoteId number
function Module:atRemoteId(remoteId)
    return self.Entities[remoteId] or nil
end

---@param vec3 vector3
---@param model? string | nil
---@param range number
function Module:getObjectsInRange(vec3, model, range)
    local collectedObjects = {}

    if type(vec3) ~= "vector3" then return end

    for k, v in pairs(self.Entities) do
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
function Module:getNearestObject(vec3, model, range, dimension)
    local rangeMeter = range
    local closest

    if type(vec3) ~= "vector3" then return end

    for k, v in pairs(self.Entities) do
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