---@class IAttachment
---@field model string
---@field boneId number
---@field x number
---@field y number
---@field z number
---@field rx number
---@field ry number
---@field rz number

---@class SharedAttachmentManager
---@field private registered table<string, IAttachment>
local AttachmentManager = {}
AttachmentManager.__index = AttachmentManager

AttachmentManager.new = function()
    local self = setmetatable({}, AttachmentManager)

    self.registered = {}

    return self
end

function AttachmentManager:exist(attachmentName)
    return self.registered[attachmentName] and true or false
end

function AttachmentManager:get(attachmentName)
    if self:exist(attachmentName) then
        return self.registered[attachmentName]
    end
    return nil
end

---@param attachmentName string
---@param d IAttachment
function AttachmentManager:registerOne(attachmentName, d)
    if self:exist(attachmentName) then
        _G.APIShared.Helpers.Logger:debug(
            string.format("Attachment is already registered: %s (it was overwritten", attachmentName)
        )
    end

    self.registered[attachmentName] = d
    _G.APIShared.Helpers.Logger:debug("Registered new attachment: " .. attachmentName)
end

---@param d table<string, IAttachment>
function AttachmentManager:registerMany(d)
    if type(d) ~= "table" then
        _G.APIShared.Helpers.Logger:error("AttachmentManager registerMany should be a key-pair table.")
        return
    end

    for k, v in pairs(d) do
        self:registerOne(k, v)
    end
end

return AttachmentManager
