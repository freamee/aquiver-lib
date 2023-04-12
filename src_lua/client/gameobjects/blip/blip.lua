---@class API_Client_BlipBase
---@field data IBlip
---@field remoteId number
---@field blipHandle number
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

function Blip:__init__()
    local blip = AddBlipForCoord(self.data.pos.x, self.data.pos.y, self.data.pos.z)
    SetBlipSprite(blip, self.data.sprite)
    SetBlipDisplay(blip, self.data.display)
    SetBlipScale(blip, self.data.scale)
    SetBlipAlpha(blip, self.data.alpha)
    SetBlipAsShortRange(blip, self.data.shortRange)
    SetBlipColour(blip, self.data.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.data.name)
    EndTextCommandSetBlipName(blip)

    self.blipHandle = blip

    TriggerEvent(_G.APIShared.resource .. ":onBlipCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new blip (%d)", self.remoteId)
    )
end

function Blip:setPosition(x, y, z)
    if self.data.pos.x == x and self.data.pos.y == y and self.data.pos.z == z then return end

    self.data.pos.x = x
    self.data.pos.y = y
    self.data.pos.z = z

    if DoesBlipExist(self.blipHandle) then
        SetBlipCoords(self.blipHandle, x, y, z)
    end
end

function Blip:setColor(colorId)
    if self.data.color == colorId then return end

    self.data.color = colorId

    if DoesBlipExist(self.blipHandle) then
        SetBlipColour(self.blipHandle, colorId)
    end
end

function Blip:destroy()
    if _G.APIClient.Managers.BlipManager.blips[self.remoteId] then
        _G.APIClient.Managers.BlipManager.blips[self.remoteId] = nil
    end

    TriggerEvent(_G.APIShared.resource .. "onBlipDestroyed", self)

    if DoesBlipExist(self.blipHandle) then
        RemoveBlip(self.blipHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed blip (%d)", self.remoteId)
    )
end

return Blip
