local Module <const> = {}
---@type { [number]: ServerActionshapeClass }
Module.Entities = {}

Server.Managers.Actionshapes = Module

---@param remoteId number
function Module:exists(remoteId)
    return self.Entities[remoteId] and true or false
end

---@param remoteId number
function Module:atRemoteId(remoteId)
    return self.Entities[remoteId] or nil
end