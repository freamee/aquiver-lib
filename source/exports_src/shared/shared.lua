local Helpers = require("shared.helpers.helpers")
local Config = require("shared.config")
local EventHandler = require("shared.eventhandler.evenhandler")
local AttachmentManager = require("shared.attachments.attachment_register")

local Shared = {}
Shared.resource = GetCurrentResourceName() --[[@as string]]
Shared.Helpers = Helpers
Shared.CONFIG = Config
Shared.EventHandler = EventHandler.new()
Shared.AttachmentManager = AttachmentManager.new()

--- Dereferencing a value. (probably item)
---@generic T
---@param a T
---@return T
function Shared:dereference(a)
    return json.decode(json.encode(a))
end

return Shared
