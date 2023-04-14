---@class API_Client_ActionshapeBase
---@field data IActionShape
---@field remoteId number
---@field isStreamed boolean
---@field isEntered boolean
local Actionshape = {}
Actionshape.__index = Actionshape

---@param remoteId number
---@param data IActionShape
Actionshape.new = function(remoteId, data)
    local self = setmetatable({}, Actionshape)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.isEntered = false

    self:__init__()

    return self
end

function Actionshape:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onActionshapeCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new actionshape (%d)", self.remoteId)
    )
end

function Actionshape:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeStreamedIn", self)

    Citizen.CreateThread(function()
        while self.isStreamed do
            DrawMarker(
                self.data.sprite,
                vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z - 1.0),
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                self.data.markerSize, self.data.markerSize, self.data.markerSize,
                self.data.color.r, self.data.color.g, self.data.color.b, self.data.color.a,
                self.data.bobUpAndDown, false, 2, self.data.rotateMarker, nil, nil, false
            )

            Citizen.Wait(1)
        end
    end)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Actionshape streamed in (%d)", self.remoteId)
    )
end

function Actionshape:removeStream()
    if not self.isStreamed then return end

    self.isStreamed = false

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Actionshape streamed out (%d)", self.remoteId)
    )
end

function Actionshape:onEnter()
    if self.isEntered then return end

    self.isEntered = true

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeEntered", self)
end

function Actionshape:onLeave()
    if not self.isEntered then return end

    self.isEntered = false

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeLeaved", self)
end

---@param vec3 vector3
function Actionshape:setPosition(vec3)
    if self.data.pos.x == vec3.x and self.data.pos.y == vec3.y and self.data.pos.z == vec3.z then return end

    self.data.pos = vector3(vec3.x, vec3.y, vec3.z)
end

function Actionshape:getVector3Position()
    return vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z)
end

---@param vec3 vector3
function Actionshape:dist(vec3)
    return #(self:getVector3Position() - vec3)
end

function Actionshape:destroy()
    if _G.APIClient.Managers.ActionshapeManager.shapes[self.remoteId] then
        _G.APIClient.Managers.ActionshapeManager.shapes[self.remoteId] = nil
    end

    self:removeStream()

    _G.APIShared.EventHandler:TriggerEvent("onActionshapeDestroyed", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed actionshape (%d)", self.remoteId)
    )
end

return Actionshape
