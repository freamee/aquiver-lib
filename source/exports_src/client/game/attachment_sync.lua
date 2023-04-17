local AttachmentSync = {}
---@type table<number, CAttachmentSyncPlayer>
AttachmentSync.players = {}

function AttachmentSync:getPlayer(serverId)
    return self.players[serverId]
end

function AttachmentSync:removePlayer(serverId)
    local target = self:getPlayer(serverId)
    if not target then return end

    target:shutdown()

    self.players[serverId] = nil

    print("REMOVED PLAYER " .. serverId)
end

---@class CAttachmentSyncPlayer
---@field serverId number
---@field attachments table<string, boolean> -- Storing the attachments
---@field attachmenthandles table<string, number> -- Storing the attachment object handles
local TargetAttachments = {}
TargetAttachments.__index = TargetAttachments

TargetAttachments.new = function(serverId, attachments)
    local self = setmetatable({}, TargetAttachments)

    self.serverId = serverId
    self.attachments = type(attachments) == "table" and attachments or {}
    self.attachmenthandles = {}

    self:init()

    AttachmentSync.players[serverId] = self

    return self
end

function TargetAttachments:init()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(self.serverId))
    if not DoesEntityExist(targetPed) then return end

    for k, v in pairs(self.attachments) do
        local attData = _G.APIShared.AttachmentManager:get(k)

        if attData and not DoesEntityExist(self.attachmenthandles[k]) then
            local coords = GetEntityCoords(targetPed)
            local modelHash = GetHashKey(attData.model)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(10)
            end
            local obj = CreateObject(modelHash, coords, false, false, false)

            AttachEntityToEntity(
                obj,
                targetPed,
                GetPedBoneIndex(targetPed, attData.boneId),
                attData.x, attData.y, attData.z,
                attData.rx, attData.ry, attData.rz,
                true, true, false, false, 2, true
            )

            self.attachmenthandles[k] = obj
        end
    end
end

function TargetAttachments:hasAttachment(attachmentName)
    return self.attachments[attachmentName] and true or false
end

function TargetAttachments:deleteAttachment(attachmentName)
    if self:hasAttachment(attachmentName) then
        if DoesEntityExist(self.attachmenthandles[attachmentName]) then
            DeleteEntity(self.attachmenthandles[attachmentName])
        end
        self.attachmenthandles[attachmentName] = nil
        self.attachments[attachmentName] = nil
    end
end

function TargetAttachments:updateAttachments(newAttachments)
    local includeNewAttachment = function(attachmentName)
        for k, v in pairs(newAttachments) do
            if k == attachmentName then
                return true
            end
        end
        return false
    end

    -- Loop through old attachments
    for k, v in pairs(self.attachments) do
        -- Delete the old attachment if its not included in the new attachments table.
        local inc = includeNewAttachment(k)
        if not inc then
            self:deleteAttachment(k)
        end
    end

    self.attachments = newAttachments
    self:init()
end

function TargetAttachments:shutdown()
    for k, v in pairs(self.attachmenthandles) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
            print("DELETED OBJECT")
        end
    end
    self.attachmenthandles = {}
    self.attachments = {}
end

AddStateBagChangeHandler(_G.APIShared.resource .. "attachments", nil, function(bagName, key, value)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end

    local serverId = GetPlayerServerId(ply)

    if type(value) == "table" then
        local target = AttachmentSync:getPlayer(serverId)
        if not target then
            target = TargetAttachments.new(serverId, value)
        else
            target:updateAttachments(value)
        end
    end
end)

CreateThread(function()
    while true do
        for k, v in pairs(AttachmentSync.players) do
            local targetPed = GetPlayerPed(GetPlayerFromServerId(k))
            if not DoesEntityExist(targetPed) then
                AttachmentSync:removePlayer(k)
            end
        end

        Wait(1000)
    end
end)

_G.APIShared.EventHandler:AddEvent("ScriptStopped", function()
    for k, v in pairs(AttachmentSync.players) do
        AttachmentSync:removePlayer(k)
    end
end)
