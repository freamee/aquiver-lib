---@class CAttachmentSyncPlayer
---@field serverId number
---@field attachments table<string, boolean> -- Storing the attachments
---@field attachmenthandles table<string, number> -- Storing the attachment object handles
---@field private isStreamed boolean
local Target = {}
Target.__index = Target

Target.new = function(serverId)
    local self = setmetatable({}, Target)

    self.serverId = serverId
    self.attachments = {}
    self.attachmenthandles = {}

    return self
end

function Target:hasAttachment(attachmentName)
    return self.attachments[attachmentName] and true or false
end

function Target:addAttachment(attachmentName)
    if self:hasAttachment(attachmentName) then return end

    self.attachments[attachmentName] = true
    self:createAttachmentObject(attachmentName)
end

function Target:getAttachmentCount()
    local count = 0
    for k, v in pairs(self.attachments) do
        count = count + 1
    end
    return count
end

function Target:removeAttachment(attachmentName)
    if not self:hasAttachment(attachmentName) then return end

    self.attachments[attachmentName] = nil
    self:removeAttachmentObject(attachmentName)
end

function Target:removeAttachmentObject(attachmentName)
    if not DoesEntityExist(self.attachmenthandles[attachmentName]) then return end

    DeleteEntity(self.attachmenthandles[attachmentName])
    self.attachmenthandles[attachmentName] = nil
end

function Target:createAttachmentObject(attachmentName)
    if DoesEntityExist(self.attachmenthandles[attachmentName]) then return end

    local attData = _G.APIShared.AttachmentManager:get(attachmentName)
    if not attData then return end

    local targetPed = self:getPed()
    if targetPed then
        local coords = GetEntityCoords(targetPed)
        local modelHash = GetHashKey(attData.model)

        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Wait(10)
        end

        local obj = CreateObject(modelHash, coords, false, false, false) --[[@as number]]

        AttachEntityToEntity(
            obj,
            targetPed,
            GetPedBoneIndex(targetPed, attData.boneId),
            attData.x, attData.y, attData.z,
            attData.rx, attData.ry, attData.rz,
            true, true, false, false, 2, true
        )

        self.attachmenthandles[attachmentName] = obj
    end
end

function Target:shutdown()
    for k, v in pairs(self.attachmenthandles) do
        self:removeAttachmentObject(k)
    end
end

function Target:init()
    for k, v in pairs(self.attachments) do
        self:createAttachmentObject(k)
    end
end

function Target:getPed()
    return GetPlayerPed(GetPlayerFromServerId(self.serverId))
end

function Target:addStream()
    if self.isStreamed then return end

    self.isStreamed = true

    self:init()
end

function Target:removeStream()
    if not self.isStreamed then return end

    self.isStreamed = false

    self:shutdown()
end

local AttachmentSyncManager = {}
---@type table<number, CAttachmentSyncPlayer>
AttachmentSyncManager.players = {}

function AttachmentSyncManager:getPlayer(serverId)
    if not self.players[serverId] then
        self.players[serverId] = Target.new(serverId)
    end

    return self.players[serverId]
end

RegisterNetEvent(_G.APIShared.resource .. "player:attachments:load", function(serverId, attachmentsData)
    local target = AttachmentSyncManager:getPlayer(serverId)
    target.attachments = attachmentsData
    target:removeStream()
end)

RegisterNetEvent(_G.APIShared.resource .. "entity:player:addAttachment", function(serverId, attachmentName)
    local target = AttachmentSyncManager:getPlayer(serverId)
    target:addAttachment(attachmentName)
end)

RegisterNetEvent(_G.APIShared.resource .. "entity:player:removeAttachment", function(serverId, attachmentName)
    local target = AttachmentSyncManager:getPlayer(serverId)
    target:removeAttachment(attachmentName)

    local count = target:getAttachmentCount()
    if count < 1 then
        AttachmentSyncManager.players[serverId] = nil
    end
end)

_G.APIShared.EventHandler:AddEvent("ScriptStopped", function()
    for k, v in pairs(AttachmentSyncManager.players) do
        v:shutdown()
    end
end)

_G.APIShared.EventHandler:AddEvent("PlayerLoaded", function()
    TriggerServerEvent(_G.APIShared.resource .. "player:attachments:request:data")
end)

CreateThread(function()
    while true do
        local playerCoords = _G.APIClient.LocalPlayer.cache.playerCoords
        local playerServerId = _G.APIClient.LocalPlayer.cache.playerServerId
        local playerDimension = _G.APIClient.LocalPlayer.dimension

        for k, v in pairs(AttachmentSyncManager.players) do
            if v.serverId ~= playerServerId then
                local targetPed = v:getPed()
                if targetPed then
                    local state = Player(k).state
                    local dist = #(playerCoords - GetEntityCoords(targetPed))
                    if dist < 25.0 and state.playerDimension == playerDimension then
                        v:addStream()
                    else
                        v:removeStream()
                    end
                end
            end
        end

        Wait(1000)
    end
end)
