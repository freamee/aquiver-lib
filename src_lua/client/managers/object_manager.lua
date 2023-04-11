local Object = require("client.gameobjects.objects.object")

---@class Client_ObjectManager
---@field objects table<number, API_Client_ObjectBase>
local ObjectManager = {}
ObjectManager.__index = ObjectManager

ObjectManager.new = function()
    local self = setmetatable({}, ObjectManager)

    self.objects = {}

    return self
end

---@param remoteId number
---@param data ISQLObject
function ObjectManager:createObject(remoteId, data)
    if self.objects[remoteId] then
        return self.objects[remoteId]
    end

    self.objects[remoteId] = Object.new(remoteId, data)

    return self.objects[remoteId]
end

function ObjectManager:getObject(remoteId)
    return self.objects[remoteId]
end

return ObjectManager
