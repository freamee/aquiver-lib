local PlayerManager = require("server.managers.player_manager")
local ObjectManager = require("server.managers.object_manager")

local Managers = {
    PlayerManager = PlayerManager.new(),
    ObjectManager = ObjectManager.new()
}

return Managers
