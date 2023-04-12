---@class IActionShape
---@field pos vector3
---@field color { r:number; g:number; b:number; a:number; }
---@field sprite number
---@field range number
---@field dimension number
---@field variables table

---@class API_Server_ActionshapeBase
---@field data IActionShape
---@field remoteId number
local Actionshape = {}
Actionshape.__index = Actionshape

---@param remoteId number
---@param data IActionShape
Actionshape.new = function(remoteId, data)
    local self = setmetatable({}, Actionshape)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

function Actionshape:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new actionshape (%d)", self.remoteId)
    )

    self.data.display = type(self.data.display) == "number" and self.data.display or 4
    self.data.shortRange = type(self.data.shortRange) == "boolean" and self.data.shortRange or true
    self.data.scale = type(self.data.scale) == "number" and self.data.scale or 1.0
    self.data.alpha = type(self.data.alpha) == "number" and self.data.alpha or 255

    TriggerEvent(_G.APIShared.resource .. ":onActionshapeCreated", self)
    self:createForPlayer(-1)
end

function Actionshape:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:create", source, self.remoteId, self.data)
end

---@param vec3 vector3
function Actionshape:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos.x = vec3.x
    self.data.pos.y = vec3.y
    self.data.pos.z = vec3.z

    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:set:position",
        -1,
        self.remoteId,
        self.data.pos.x,
        self.data.pos.y,
        self.data.pos.z
    )
end

function Actionshape:destroy()
    if _G.APIServer.Managers.ActionshapeManager.shapes[self.remoteId] then
        _G.APIServer.Managers.ActionshapeManager.shapes[self.remoteId] = nil
    end

    TriggerEvent(_G.APIShared.resource .. "onActionshapeDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "actionshapes:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed actionshape (%d)", self.remoteId)
    )
end

return Actionshape
