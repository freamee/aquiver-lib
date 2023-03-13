function Server.Classes.Players(source)
    ---@class ServerPlayerClass
    ---@field source number
    ---@field variables { [string]: any }
    ---@field dimension number
    local self = {}

    if type(source) ~= "number" then source = tonumber(source) end
    if source == nil then return end

    self.source = source
    self.variables = {}
    self.dimension = GetPlayerRoutingBucket(self.source)

    if Server.Managers.Players:exists(self.source) then
        Shared.Utils:Error("Player already exists with sourceID: " .. self.source)
        return
    end

    self.getVar = function(key)
        return type(self.variables[key]) ~= "nil" and self.variables[key] or nil
    end

    self.setVar = function(key, value)
        if self.variables[key] == value then return end

        self.variables[key] = value

        TriggerClientEvent("onPlayerVariableChange", self.source, key, value)
        TriggerEvent("onPlayerVariableChange", self, key, value)
    end

    self.destroy = function()
        if Server.Managers.Players:exists(self.source) then
            Server.Managers.Players.Entities[self.source] = nil
        end
    
        Shared.Utils:Debug("Removed player with sourceID: " .. self.source)
    end

    Server.Managers.Players.Entities[self.source] = self

    Shared.Utils:Debug("Created new Player with sourceID: " .. self.source)

    TriggerEvent("onPlayerLoaded", self)

    return self
end