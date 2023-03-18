local Module <const> = {}
Module.cache = {
    playerId = nil,
    playerPed = nil,
    playerServerId = nil,
    playerCoords = nil,
    playerHeading = nil
}
---@type { [string]: IHelp }
Module.cachedHelps = {}

Client.LocalPlayer = Module

function Module.cacheNow()
    Module.cache.playerId = PlayerId()
    Module.cache.playerPed = PlayerPedId()
    Module.cache.playerServerId = GetPlayerServerId(Module.cache.playerId)
    Module.cache.playerCoords = GetEntityCoords(Module.cache.playerPed)
    Module.cache.playerHeading = GetEntityHeading(Module.cache.playerPed)
end

---@param helpData IHelp
function Module.addHelp(helpData)
    -- If help entry not exists add it.
    if not Module.cachedHelps[helpData.uid] then
        Module.cachedHelps[helpData.uid] = {
            image = helpData.image,
            key = helpData.key,
            msg = helpData.msg,
            uid = helpData.uid,
            icon = helpData.icon
        }

        SendCefMessage({
            event = "HELP_ADD",
            uid = helpData.uid,
            msg = helpData.msg,
            key = helpData.key,
            image = helpData.image,
            icon = helpData.icon
        })

        PlaySoundFrontend(-1, "SELECT", "HUD_FREEMODE_SOUNDSET", true)
    else
        -- If help Entry exists, we update it if it differs.
        if Module.cachedHelps[helpData.uid].msg ~= helpData.msg or
            Module.cachedHelps[helpData.uid].key ~= helpData.key or
            Module.cachedHelps[helpData.uid].image ~= helpData.image or
            Module.cachedHelps[helpData.uid].icon ~= helpData.icon
        then

            Module.cachedHelps[helpData.uid].msg = helpData.msg
            Module.cachedHelps[helpData.uid].key = helpData.key
            Module.cachedHelps[helpData.uid].image = helpData.image
            Module.cachedHelps[helpData.uid].icon = helpData.icon

            SendCefMessage({
                event = "HELP_UPDATE",
                uid = helpData.uid,
                key = helpData.key,
                msg = helpData.msg,
                image = helpData.image,
                icon = helpData.icon
            })
        end
    end
end

---@param uid string
function Module.removeHelp(uid)
    if not Module.cachedHelps[uid] then return end

    Module.cachedHelps[uid] = nil

    SendCefMessage({
        event = "HELP_REMOVE",
        uid = uid
    })
end

---@param type "error" | "success" | "info" | "warning"
---@param message string
function Module.notification(type, message)
    SendCefMessage({
        event = "SEND_NOTIFICATION",
        type = type,
        message = message
    })
end

Module.cacheNow()

Citizen.CreateThread(function()
    while true do
        Module.cacheNow()
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent("PLAYER_ADD_HELP", function(helpData)
    Module.addHelp(helpData)
end)
RegisterNetEvent("PLAYER_REMOVE_HELP", function(uid)
    Module.removeHelp(uid)
end)
RegisterNetEvent("PLAYER_SEND_NOTIFICATION", function(type, message)
    Module.notification(type, message)
end)