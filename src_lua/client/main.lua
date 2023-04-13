local Shared = require("shared.shared")

local Config = require("client.config")
local Managers = require("client.managers.managers")
local Helpers = require("client.helpers.helpers")
local Game = require("client.game.game")

_G.APIShared = Shared

_G.APIClient = {}
_G.APIClient.Game = Game
_G.APIClient.Managers = Managers
_G.APIClient.Helpers = Helpers
_G.APIClient.CONFIG = Config

-- Events needs to be loaded after the _G.APIClient initialized.
require("client.events.events")
