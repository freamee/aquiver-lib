local Module <const> = {}
Module.isEnabled = false
---@type number
Module.currentHitHandle = nil
---@type ClientObjectClass
Module.AimedObjectEntity = nil
---@type ClientPedClass
Module.AimedPedEntity = nil

Client.Raycast = Module

function Module.setEntityHandle(handleId)
    -- Do not trigger if its the same as before...
    if Module.currentHitHandle == handleId then return end

    Module.currentHitHandle = handleId

    if Module.currentHitHandle then
        -- Caching the class entity itself, so we do not have to loop the table always.
        if GetEntityType(Module.currentHitHandle) == 1 then
            local findPed = Client.Managers.Peds.atHandle(Module.currentHitHandle)
            if findPed then
                Module.AimedPedEntity = findPed
                TriggerEvent("onPedRaycast", findPed)
                Shared.Utils.Debug(string.format("Raycast entity changed: Ped: (%d, %s)", findPed.remoteId, findPed.data.model))
            end
        elseif GetEntityType(Module.currentHitHandle) == 3 then
            local findObject = Client.Managers.Objects.atHandle(Module.currentHitHandle)
            if findObject then
                Module.AimedObjectEntity = findObject
                TriggerEvent("onObjectRaycast", findObject)
                Shared.Utils.Debug(string.format("Raycast entity changed: Object: (%d, %s)", findObject.remoteId, findObject.data.model))
            end
        end

        Citizen.CreateThread(function()
            while Module.currentHitHandle == handleId do

                Client.Utils:DrawSprite2D(
                    0.5,
                    0.5,
                    CONFIG.RAYCAST.SPRITE_DICT,
                    CONFIG.RAYCAST.SPRITE_NAME,
                    0.75,
                    0,
                    CONFIG.RAYCAST.SPRITE_COLOR.r,
                    CONFIG.RAYCAST.SPRITE_COLOR.g,
                    CONFIG.RAYCAST.SPRITE_COLOR.b,
                    CONFIG.RAYCAST.SPRITE_COLOR.a
                )

                Citizen.Wait(1)
            end
        end)
    else
        Module.AimedObjectEntity = nil
        Module.AimedPedEntity = nil
        TriggerEvent("onNullRaycast")
        Shared.Utils.Debug("Raycast entity changed: NULL")
    end
end

function Module.enable(state)
    if Module.isEnabled == state then return end

    Module.isEnabled = state

    if Module.isEnabled then
        Citizen.CreateThread(function()
            while Module.isEnabled do

                local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
                local destination = coords + normal * 10
                local handle = StartShapeTestCapsule(
                    coords.x,
                    coords.y,
                    coords.z,
                    destination.x,
                    destination.y,
                    destination.z,
                    CONFIG.RAYCAST.RAY_RANGE,
                    9,
                    Client.LocalPlayer.cache.playerPed,
                    4
                )

                local _, hit, endCoords, surfaceNormal, hitHandle = GetShapeTestResult(handle)

                if hit then
                    local entityType = GetEntityType(hitHandle)

                    -- Check if Object
                    if entityType == 3 then
                        local findObject = Client.Managers.Objects.atHandle(hitHandle)
                        if findObject then
                            local dist = findObject.dist(Client.LocalPlayer.cache.playerCoords)
                            if dist < 2.5 then
                                Module.setEntityHandle(hitHandle)
                                goto continue
                            end
                        end
                    elseif entityType == 1 then
                        local findPed = Client.Managers.Peds.atHandle(hitHandle)
                        if findPed then
                            local dist = findPed.dist(Client.LocalPlayer.cache.playerCoords)
                            if dist < 2.5 then
                                Module.setEntityHandle(hitHandle)
                                goto continue
                            end
                        end
                    end
                end

                -- Reset here if its not continued
                Module.setEntityHandle(nil)

                ::continue::
                Citizen.Wait(CONFIG.RAYCAST.INTERVAL)
            end
        end)
    else
        Module.setEntityHandle(nil)
    end
end