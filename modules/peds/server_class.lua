local remoteIdCounter = 1

---@class IPed
---@field uid? string
---@field x number
---@field y number
---@field z number
---@field heading number
---@field model string
---@field dimension number
---@field animDict? string
---@field animName? string
---@field animFlag? number
---@field questionMark? boolean
---@field name? string

---@param data IPed
function Server.Classes.Peds(data)
    ---@class ServerPedClass
    ---@field data IPed
    ---@field remoteId number
    local self = {}

    self.data = data
    self.remoteId = remoteIdCounter

    remoteIdCounter += 1

    if Server.Managers.Peds:exists(self.remoteId) then
        Shared.Utils:Error(string.format("Ped already exists. (%d, %s)", self.remoteId, self.data.model))
        return
    end

    self.destroy = function()
        if Server.Managers.Peds:exists(self.remoteId) then
            Server.Managers.Peds.Entities[self.remoteId] = nil
        end

        TriggerEvent("onPedDestroyed", self)
        TriggerClientEvent("AquiverLib:Ped:Destroy", -1, self.remoteId)

        Shared.Utils:Debug(string.format("Removed ped (%d, %s)", self.remoteId, self.data.model))
    end

    Server.Managers.Peds.Entities[self.remoteId] = self

    TriggerClientEvent("AquiverLib:Ped:Create", -1, self.remoteId, self.data)

    TriggerEvent("onPedCreated", self)

    Shared.Utils:Debug(string.format("Created new ped (%d, %s)", self.remoteId, self.data.model))

    return self
end