local Module <const> = {}
---@type { [number]: ServerBlipClass }
Module.Entities = {}

Server.Managers.Blips = Module

---@param remoteId number
function Module.exists(remoteId)
    return Module.Entities[remoteId] and true or false
end

---@param remoteId number
function Module.atRemoteId(remoteId)
    return Module.Entities[remoteId] or nil
end