local Module <const> = {}
---@type { [number]: ClientActionshapeClass }
Module.Entities = {}
---@type { [number]: ClientActionshapeClass }
Module.Streamed = {}
Module.streamedCount = 0
Module.streamThreadActive = false

Client.Managers.Actionshapes = Module

---@param remoteId number
function Module.exists(remoteId)
    return Module.Entities[remoteId] and true or false
end

---@param remoteId number
function Module.atRemoteId(remoteId)
    return Module.Entities[remoteId] or nil
end

function Module.streamingThread()
    if Module.streamedCount > 0 then
        if not Module.streamThreadActive then

            Module.streamThreadActive = true

            Citizen.CreateThread(function()
                while Module.streamThreadActive do

                    for k, value in pairs(Module.Streamed) do
                        DrawMarker(
                            value.data.sprite,
                            value.data.x, value.data.y, value.data.z - 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            1.0, 1.0, 1.0,
                            value.data.color.r, value.data.color.g, value.data.color.b, value.data.color.a,
                            false, false, 2, false, nil, nil, false
                        )
                    end

                    Citizen.Wait(1)
                end
            end)
        end
    else
        if Module.streamThreadActive then
            Module.streamThreadActive = false
        end
    end
end