local Module <const> = {}
---@type { [number]: ClientBlipClass }
Module.Entities = {}

Client.Managers.Blips = Module

---@param remoteId number
function Module.exists(remoteId)
    return Module.Entities[remoteId] and true or false
end

---@param remoteId number
function Module.atRemoteId(remoteId)
    return Module.Entities[remoteId] or nil
end

function Module.atHandle(handleId)
    for k, v in pairs(Module.Entities) do
        if v.blipHandle == handleId then
            return v
        end
    end
end