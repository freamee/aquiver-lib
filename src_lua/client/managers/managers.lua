local ObjectManager = require("client.managers.object_manager")
local PedManager = require("client.managers.ped_manager")
local ActionshapeManager = require("client.managers.actionshape_manager")

local Managers = {
    ObjectManager = ObjectManager.new(),
    PedManager = PedManager.new(),
    ActionshapeManager = ActionshapeManager.new()
}

return Managers
