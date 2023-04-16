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

return Shared
