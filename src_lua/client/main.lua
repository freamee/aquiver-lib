local Shared = require("shared.shared")

local Config = require("client.config")
local Managers = require("client.managers.managers")

_G.APIShared = Shared

_G.APIClient = {}
_G.APIClient.Managers = Managers
_G.APIClient.resource = GetCurrentResourceName() --[[@as string]]
_G.APIClient.CONFIG = Config

-- Events needs to be loaded after the _G.APIClient initialized.
require("client.events.events")
