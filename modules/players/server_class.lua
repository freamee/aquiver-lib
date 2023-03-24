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

    if Server.Managers.Players.exists(self.source) then
        Shared.Utils.Error("Player already exists with sourceID: " .. self.source)
        return
    end

    self.sendCefMessage = function(ctx)
        TriggerClientEvent("SEND_CEF_MESSAGE", self.source, ctx)
    end

    ---@return nil | any
    self.getVar = function(key)
        return type(self.variables[key]) ~= "nil" and self.variables[key] or nil
    end

    self.setVar = function(key, value)
        if self.variables[key] == value then return end

        self.variables[key] = value

        TriggerClientEvent("onPlayerVariableChange", self.source, key, value)
        TriggerEvent("onPlayerVariableChange", self, key, value)
    end

    ---@param x number
    ---@param y number
    ---@param z number
    self.setPosition = function(x, y, z)
        SetEntityCoords(GetPlayerPed(self.source), x, y, z, false, false, false, false)
    end

    ---@param dimension number
    self.setDimension = function(dimension)
        SetPlayerRoutingBucket(self.source, dimension)
    end

    self.getDimension = function()
        return GetPlayerRoutingBucket(self.source)
    end

    ---@param type "error" | "success" | "info" | "warning"
    ---@param message string
    self.notification = function(type, message)
        TriggerClientEvent("PLAYER_SEND_NOTIFICATION", self.source, type, message)
    end

    ---@param helpData IHelp
    self.addHelp = function(helpData)
        TriggerClientEvent("PLAYER_ADD_HELP", self.source, helpData)
    end

    ---@param uid string
    self.removeHelp = function(uid)
        TriggerClientEvent("PLAYER_REMOVE_HELP", self.source, uid)
    end

    ---@return string | nil
    self.getIdentifier = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getIdentifier()
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
            if not xPlayer then return end
            return xPlayer.getGroup()
        else
            return "admin"
        end
    end

    self.getJobName = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getJob().name --[[@as string]]
        else
            return "police"
        end
    end

    self.getJobGrade = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getJob().grade --[[@as number]]
        else
            return 0
        end
    end

    self.getName = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getName()
        else
            return GetPlayerName(self.source)
        end
    end

    self.setMoney = function(money)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.setMoney(money)
        else

        end
    end

    self.getMoney = function()
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getMoney()
        else

        end
    end

    ---@param amount number
    self.addMoney = function(amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.addMoney(amount)
        else

        end
    end

    ---@param amount number
    self.removeMoney = function(amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.removeMoney(amount)
        else

        end
    end

    ---@param accountName string
    self.getAccount = function(accountName)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getAccount(accountName)
        else

        end
    end

    ---@param accountName string
    ---@param amount number
    self.addAccountMoney = function(accountName, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.addAccountMoney(accountName, amount)
        else

        end
    end

    ---@param accountName string
    ---@param amount number
    self.removeAccountMoney = function(accountName, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.removeAccountMoney(accountName, amount)
        else

        end
    end

    ---@param name string
	self.getInventoryItem = function(name)
		if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            return xPlayer.getInventoryItem(name)
        else

        end
	end

    ---@param name string
    ---@param amount number
    self.addInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.addInventoryItem(name, amount)
        else

        end
    end

    ---@param name string
    ---@param amount number
    self.removeInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.removeInventoryItem(name, amount)
        else

        end
    end

    ---@param name string
    ---@param amount number
    self.setInventoryItem = function(name, amount)
        if Server.ESX then
            local xPlayer = Server.ESX.GetPlayerFromId(self.source)
            if not xPlayer then return end
            xPlayer.setInventoryItem(name, amount)
        else

        end
    end

    self.destroy = function()
        if Server.Managers.Players.exists(self.source) then
            Server.Managers.Players.Entities[self.source] = nil
        end
    
        Shared.Utils.Debug("Removed player with sourceID: " .. self.source)
    end

    Server.Managers.Players.Entities[self.source] = self

    Shared.Utils.Debug("Created new Player with sourceID: " .. self.source)

    TriggerEvent("onPlayerLoaded", self)

    return self
end