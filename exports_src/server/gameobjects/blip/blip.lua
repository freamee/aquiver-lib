---@class IBlip
---@field pos vector3
---@field alpha number
---@field color number
---@field sprite number
---@field name string
---@field display? number
---@field shortRange? boolean
---@field scale? number

---@class API_Server_BlipBase
---@field data IBlip
---@field remoteId number
local Blip = {}
Blip.__index = Blip

---@param remoteId number
---@param data IBlip
Blip.new = function(remoteId, data)
    local self = setmetatable({}, Blip)

    self.data = data
    self.remoteId = remoteId

    self:__init__()

    return self
end

---@private
function Blip:__init__()
    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new blip (%d)", self.remoteId)
    )

    self.data.display = type(self.data.display) == "number" and self.data.display or 4
    self.data.shortRange = type(self.data.shortRange) == "boolean" and self.data.shortRange or true
    self.data.scale = type(self.data.scale) == "number" and self.data.scale or 1.0
    self.data.alpha = type(self.data.alpha) == "number" and self.data.alpha or 255

    _G.APIShared.EventHandler:TriggerEvent("onBlipCreated", self)

    self:createForPlayer(-1)
end

function Blip:createForPlayer(source)
    TriggerClientEvent(_G.APIShared.resource .. "blips:create", source, self.remoteId, self.data)
end

---@param colorId number
function Blip:setColor(colorId)
    if self.data.color == colorId then return end

    self.data.color = colorId

    TriggerClientEvent(_G.APIShared.resource .. "blips:set:color", -1, self.remoteId, colorId)
end

---@param vec3 vector3
function Blip:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos = vec3

    TriggerClientEvent(_G.APIShared.resource .. "blips:set:position", -1, self.remoteId, x, y, z)
end

function Blip:destroy()
    if _G.APIServer.Managers.BlipManager.blips[self.remoteId] then
        _G.APIServer.Managers.BlipManager.blips[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onBlipDestroyed", self)

    TriggerClientEvent(_G.APIShared.resource .. "blips:destroy", -1, self.remoteId)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed blip (%d)", self.remoteId)
    )
end

return Blip
