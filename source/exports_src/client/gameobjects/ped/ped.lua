---@class API_Client_PedBase
---@field data IPed
---@field remoteId number
---@field isStreamed boolean
---@field pedHandle number
local Ped = {}
Ped.__index = Ped

---@param remoteId number
---@param data IPed
Ped.new = function(remoteId, data)
    local self = setmetatable({}, Ped)

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.pedHandle = nil

    self:__init__()

    return self
end

function Ped:__init__()
    _G.APIShared.EventHandler:TriggerEvent("onPedCreated", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Created new ped (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    local modelHash = GetHashKey(self.data.model)
    if not IsModelValid(modelHash) then return end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local ped = CreatePed(0, modelHash, self:getVector3Position(), self.data.heading, false, false)
    SetEntityCanBeDamaged(ped, false)
    SetPedAsEnemy(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedResetFlag(ped, 249, 1)
    SetPedConfigFlag(ped, 185, true)
    SetPedConfigFlag(ped, 108, true)
    SetPedConfigFlag(ped, 208, true)
    SetPedCanEvasiveDive(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedCanRagdoll(ped, false)
    SetPedDefaultComponentVariation(ped)

    SetEntityCoordsNoOffset(ped, self:getVector3Position(), false, false, false)
    SetEntityHeading(ped, self.data.heading)
    FreezeEntityPosition(ped, true)

    self.pedHandle = ped

    -- Re-apply scenario.
    self:setScenario(self.data.scenario)
    -- Re-apply animation.
    self:setAnimation(self.data.animDict, self.data.animName, self.data.animFlag)

    if self.data.questionMark or self.data.name then
        CreateThread(function()
            while self.isStreamed do
                local playerCoords = _G.APIClient.LocalPlayer.cache.playerCoords
                local dist = #(playerCoords - self:getVector3Position())
                if dist < 5 then
                    local onScreen = IsEntityOnScreen(self.pedHandle)

                    if self.data.questionMark then
                        DrawMarker(
                            32,
                            vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z + 1.35),
                            0, 0, 0,
                            0, 0, 0,
                            0.35, 0.35, 0.35,
                            255, 255, 0, 200,
                            true, false, 2, true, nil, nil, false
                        )
                    end

                    if self.data.name then
                        _G.APIClient.Helpers:drawText3D(
                            self.data.pos.x,
                            self.data.pos.y,
                            self.data.pos.z + 1,
                            self.data.name,
                            0.28
                        )
                    end

                    if not onScreen then
                        Wait(500)
                    end
                else
                    Wait(1000)
                end

                Wait(1)
            end
        end)
    end

    _G.APIShared.EventHandler:TriggerEvent("onPedStreamedIn", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Ped streamed in (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:removeStream()
    if not self.isStreamed then return end

    if DoesEntityExist(self.pedHandle) then
        DeleteEntity(self.pedHandle)
    end

    self.isStreamed = false

    _G.APIShared.EventHandler:TriggerEvent("onPedStreamedOut", self)

    _G.APIShared.Helpers.Logger:debug(
        string.format("Ped streamed out (%d, %s)", self.remoteId, self.data.model)
    )
end

function Ped:getVector3Position()
    return vector3(self.data.pos.x, self.data.pos.y, self.data.pos.z)
end

---@param vec3 vector3
function Ped:dist(vec3)
    return #(self:getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
end

---@param scenario string
function Ped:setScenario(scenario)
    self.data.scenario = scenario

    if self.data.scenario and DoesEntityExist(self.pedHandle) then
        TaskStartScenarioInPlace(self.pedHandle, self.data.scenario, 0, false)
    end
end

function Ped:setAnimation(dict, name, flag)
    self.data.animDict = dict
    self.data.animName = name
    self.data.animFlag = flag

    if self.data.animDict and self.data.animName and self.data.animFlag and DoesEntityExist(self.pedHandle) then
        local tries, failed = 0, false

        RequestAnimDict(self.data.animDict)
        while not HasAnimDictLoaded(self.data.animDict) and not failed do
            tries = tries + 1

            if tries > 100 then
                failed = true
                _G.APIShared.Helpers.Logger:error("Failed to load animDict. (PED)")
            end

            Citizen.Wait(50)
        end

        if not failed then
            TaskPlayAnim(
                self.pedHandle,
                self.data.animDict,
                self.data.animName,
                1.0,
                1.0,
                -1,
                tonumber(self.data.animFlag),
                1.0,
                false,
                false,
                false
            )
        end
    end
end

function Ped:destroy()
    if _G.APIClient.Managers.PedManager.peds[self.remoteId] then
        _G.APIClient.Managers.PedManager.peds[self.remoteId] = nil
    end

    _G.APIShared.EventHandler:TriggerEvent("onPedDestroyed", self)

    if DoesEntityExist(self.pedHandle) then
        DeleteEntity(self.pedHandle)
    end

    _G.APIShared.Helpers.Logger:debug(
        string.format("Removed ped (%d, %s)", self.remoteId, self.data.model)
    )
end

return Ped
