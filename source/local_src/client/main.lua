RegisterNetEvent("aquiver-lib:sendApiMessage", function(jsonContent)
    SendNUIMessage(jsonContent)
end)

RegisterNUICallback("focus_nui", function(state, cb)
    SetNuiFocus(state, state)
    cb({})
end)

RegisterNUICallback("trigger_client", function(d, cb)
    local event, args = d.event, d.args
    TriggerEvent(event, args)
    cb({})
end)
RegisterNUICallback("trigger_server", function(d, cb)
    local event, args = d.event, d.args
    TriggerServerEvent(event, args)
    cb({})
end)
