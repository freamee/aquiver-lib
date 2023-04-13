---@class Client_RaycastSystem
---@field private isEnabled boolean
---@field private currentHitHandle number | nil
---@field renderInterval Interval_Class
---@field findInterval Interval_Class
local Raycast = {}
Raycast.__index = Raycast

Raycast.new = function()
    local self = setmetatable({}, Raycast)

    self.isEnabled = false
    self.currentHitHandle = nil

    Citizen.CreateThread(function()
        self.renderInterval = _G.APIShared.Helpers.Interval.new(1, function()
            _G.APIClient.Helpers:drawText2D(0.5, 0.5, "Ray")
        end)
        self.findInterval = _G.APIShared.Helpers.Interval.new(300, function()
            local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
            local destination = coords + normal * 8
            local handle = StartShapeTestCapsule(
                coords.x,
                coords.y,
                coords.z,
                destination.x,
                destination.y,
                destination.z,
                0.15,
                16,
                PlayerPedId(),
                4
            )

            local _, hit, endCoords, surfaceNormal, hitHandle = GetShapeTestResult(handle)

            if hit and DoesEntityExist(hitHandle) then
                self:setEntityHandle(hitHandle)
            else
                self:setEntityHandle(nil)
            end
        end)
        -- self.renderInterval = _G.SharedGlobals.Helpers.Interval.new(1, function()
        --     _G.ClientGlobals.Helpers.UtilsHelper:drawSprite2D({
        --         screenX = 0.5,
        --         screenY = 0.5,
        --         textureDict = "mphud",
        --         textureName = "spectating",
        --         scale = 0.75,
        --         rotation = 0,
        --         r = 255,
        --         g = 255,
        --         b = 255,
        --         a = 200
        --     })
        -- end)
    end)

    return self
end

---@param handleId number | nil
function Raycast:setEntityHandle(handleId)
    if self.currentHitHandle == handleId then return end

    self.currentHitHandle = handleId

    if self.currentHitHandle then
        if self.renderInterval then
            self.renderInterval:start()
        end
    else
        if self.renderInterval then
            self.renderInterval:stop()
        end
    end
end

---@param state boolean
function Raycast:enable(state)
    if self.isEnabled == state then return end

    self.isEnabled = state

    if self.isEnabled then
        if self.findInterval then
            self.findInterval:start()
        end
    else
        if self.findInterval then
            self.findInterval:stop()
        end
        self:setEntityHandle(nil)
    end
end

return Raycast