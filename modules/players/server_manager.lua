local Module = {}
---@type { [number]: ServerPlayerClass }
Module.Entities = {}

Server.Managers.Players = Module

function Module:exists(source)
    if type(source) ~= "number" then source = tonumber(source) end
    if source == nil then return end

    return self.Entities[source] and true or false
end

function Module:get(source)
    if type(source) ~= "number" then source = tonumber(source) end
    if source == nil then return end

    return self.Entities[source] or nil
end