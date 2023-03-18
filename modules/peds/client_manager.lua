local Module <const> = {}
---@type { [number]: ClientPedClass }
Module.Entities = {}

Client.Managers.Peds = Module

---@param remoteId number
function Module.exists(remoteId)
    return Module.Entities[remoteId] and true or false
end

---@param remoteId number
function Module.atRemoteId(remoteId)
    return Module.Entities[remoteId] or nil
end

---@param uid string
function Module.atUid(uid)
    for k, v in pairs(Module.Entities) do
        if v.data.uid == uid then
            return v
        end
    end
end

function Module.atHandle(handleId)
    for k, v in pairs(Module.Entities) do
        if v.pedHandle == handleId then
            return v
        end
    end
end