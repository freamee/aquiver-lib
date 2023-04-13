---@class Client_RaycastSystem
---@field private isEnabled boolean
---@field protected currentHitHandle number | nil
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
            _G.APIClient.Helpers:drawSprite2D({
                screenX = 0.5,
                screenY = 0.5,
                textureDict = "mphud",
                textureName = "spectating",
                scale = 0.75,
                rotation = 0,
                r = 200,
                g = 200,
                b = 200,
                a = 155
            })
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
                if self.currentHitHandle == hitHandle then
                    return true
                end

                local entityType = GetEntityType(hitHandle)
                if entityType == 1 then -- Ped entity type
                    local ped = _G.APIClient.Managers.PedManager:atHandle(hitHandle)
                    if ped then
                        self:setEntityHandle(hitHandle)
                        _G.APIShared.EventHandler:TriggerEvent("onPedRaycast", ped)
                        return true         -- Important return here
                    end
                elseif entityType == 3 then -- Object entity type
                    local object = _G.APIClient.Managers.ObjectManager:atHandle(hitHandle)
                    if object then
                        self:setEntityHandle(hitHandle)
                        _G.APIShared.EventHandler:TriggerEvent("onObjectRaycast", object)
                        return true -- Important return here
                    end
                end
            end

            self:setEntityHandle(nil)
        end)
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

        _G.APIShared.EventHandler:TriggerEvent("onNullRaycast")
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

function Raycast:hasRaycastTarget()
    return self.currentHitHandle ~= nil
end

function Raycast:getRaycastTarget()
    return self.currentHitHandle
end

return Raycast
