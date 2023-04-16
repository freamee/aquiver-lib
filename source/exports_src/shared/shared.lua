local Helpers = require("shared.helpers.helpers")
local Config = require("shared.config")
local EventHandler = require("shared.eventhandler.evenhandler")

local Shared = {}
Shared.resource = GetCurrentResourceName() --[[@as string]]
Shared.Helpers = Helpers
Shared.CONFIG = Config
Shared.EventHandler = EventHandler.new()

return Shared
