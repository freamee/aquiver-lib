local ObjectManager = require("client.managers.object_manager")
local PedManager = require("client.managers.ped_manager")

local Managers = {
    ObjectManager = ObjectManager.new(),
    PedManager = PedManager.new()
}

return Managers
