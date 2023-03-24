---@param remoteId number
---@param data IPed
function Client.Classes.Peds(remoteId, data)
    ---@class ClientPedClass
    ---@field data IPed
    ---@field remoteId number
    ---@field isStreamed boolean
    ---@field pedHandle number
    local self = {}

    self.data = data
    self.remoteId = remoteId
    self.isStreamed = false
    self.pedHandle = nil

    if Client.Managers.Peds.exists(self.remoteId) then
        Shared.Utils.Error(string.format("Ped already exists. (%d, %s)", self.remoteId, self.data.model))
        return
    end

    self.getVector3Position = function()
        return vector3(self.data.x, self.data.y, self.data.z)
    end

    self.getHeading = function()
        return self.data.heading
    end

    ---@param vec3 vector3
    self.dist = function(vec3)
        return #(self.getVector3Position() - vector3(vec3.x, vec3.y, vec3.z))
    end

    ---@param scenarioName string
    self.setScenario = function(scenarioName)
        self.data.scenario = scenarioName

        if self.data.scenario and DoesEntityExist(self.pedHandle) then
            TaskStartScenarioInPlace(self.pedHandle, self.data.scenario, 0, false)
        end
    end

    self.addStream = function()
        if self.isStreamed then return end

        self.isStreamed = true

        local modelHash = GetHashKey(self.data.model)
        if not IsModelValid(modelHash) then return end

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(100)
        end
    
        local ped = CreatePed(0, modelHash, self.getVector3Position(), self.getHeading(), false, false)
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
    
        SetEntityCoordsNoOffset(ped, self.getVector3Position(), false, false, false)
        SetEntityHeading(ped, self.getHeading())
        FreezeEntityPosition(ped, true)
    
        self.pedHandle = ped

        -- Just reapply scenario here.
        self.setScenario(self.data.scenario)
      
        Shared.Utils.Debug(string.format("Ped streamed in (%d, %s)", self.remoteId, self.data.model))
    
        if self.data.questionMark or self.data.name then
            Citizen.CreateThread(function()
                while self.isStreamed do
                    local dist = #(Client.LocalPlayer.cache.playerCoords - self.getVector3Position())
    
                    local onScreen = false
                    if dist < 5.0 then
                        onScreen = IsEntityOnScreen(self.pedHandle)
    
                        if self.data.questionMark then
                            DrawMarker(
                                32,
                                self.data.x, self.data.y, self.data.z + 1.35,
                                0, 0, 0,
                                0, 0, 0,
                                0.35, 0.35, 0.35,
                                255, 255, 0, 200,
                                true, false, 2, true, nil, nil, false
                            )
                        end
    
                        if self.data.name then
                            Client.Utils:DrawText3D(
                                self.data.x,
                                self.data.y,
                                self.data.z + 1,
                                self.data.name,
                                0.28
                            )
                        end
                    else
                        Citizen.Wait(500)
                    end
    
                    if not onScreen then
                        Citizen.Wait(500)
                    end
    
                    Citizen.Wait(1)
                end
            end)
        end
    end

    self.removeStream = function()
        if not self.isStreamed then return end

        self.isStreamed = false
    
        if DoesEntityExist(self.pedHandle) then
            DeleteEntity(self.pedHandle)
        end
    
        Shared.Utils.Debug(string.format("Ped streamed out (%d, %s)", self.remoteId, self.data.model))
    end

    self.destroy = function()
        if Client.Managers.Peds.exists(self.remoteId) then
            Client.Managers.Peds.Entities[self.remoteId] = nil
        end

        self.removeStream()

        TriggerEvent("onPedDestroyed", self)

        Shared.Utils.Debug(string.format("Removed ped (%d, %s)", self.remoteId, self.data.model))
    end

    Client.Managers.Peds.Entities[self.remoteId] = self

    Shared.Utils.Debug(string.format("Created new ped (%d, %s)", self.remoteId, self.data.model))

    return self
end