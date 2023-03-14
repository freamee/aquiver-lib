local Module <const> = {}
---@type { [number]: ClientBlipClass }
Module.Entities = {}

Client.Managers.Blips = Module

---@param remoteId number
function Module:exists(remoteId)
    return self.Entities[remoteId] and true or false
end

---@param remoteId number
function Module:atRemoteId(remoteId)
    return self.Entities[remoteId] or nil
end

function Module:atHandle(handleId)
    for k, v in pairs(self.Entities) do
        if v.blipHandle == handleId then
            return v
        end
    end
end