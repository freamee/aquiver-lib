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

    self.getIdentifier = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getIdentifier()
        else
            for _, v in pairs(GetPlayerIdentifiers(source)) do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    return v
                end
            end
        end
    end

    self.getGroup = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getGroup()
        else
            return "admin"
        end
    end

    self.getJob = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getJob()
        else
            return "police"
        end
    end

    self.getName = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getName()
        else
            return GetPlayerName(self.source)
        end
    end

    self.setMoney = function(money)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.setMoney(money)
        else

        end
    end

    self.getMoney = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getMoney()
        else

        end
    end

    ---@param amount number
    self.addMoney = function(amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.addMoney(amount)
        else

        end
    end

    ---@param amount number
    self.removeMoney = function(amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.removeMoney(amount)
        else

        end
    end

    ---@param accountName string
    self.getAccount = function(accountName)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getAccount(accountName)
        else

        end
    end

    ---@param accountName string
    ---@param amount number
    self.addAccountMoney = function(accountName, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.addAccountMoney(accountName, amount)
        else

        end
    end

    ---@param accountName string
    ---@param amount number
    self.removeAccountMoney = function(accountName, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.removeAccountMoney(accountName, amount)
        else

        end
    end

    ---@param name string
	self.getInventoryItem = function(name)
		if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            return (xPlayer) and xPlayer.getInventoryItem(name)
        else

        end
	end

    ---@param name string
    ---@param amount number
    self.addInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.addInventoryItem(name, amount)
        else

        end
    end

    ---@param name string
    ---@param amount number
    self.removeInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.removeInventoryItem(name, amount)
        else

        end
    end

    ---@param name string
    ---@param amount number
    self.setInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            (xPlayer) and xPlayer.setInventoryItem(name, amount)
        else

        end
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