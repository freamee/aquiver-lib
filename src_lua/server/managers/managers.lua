local PlayerManager = require("server.managers.player_manager")
local ObjectManager = require("server.managers.object_manager")
local BlipManager = require("server.managers.blip_manager")

local Managers = {
    PlayerManager = PlayerManager.new(),
    ObjectManager = ObjectManager.new(),
    BlipManager = BlipManager.new()
}

return Managers
