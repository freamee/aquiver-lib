Client = {}
Client.Classes = {}
Client.Managers = {}

exports("getClient", function()
    return Client
end)

function SendCefMessage(ctx)
    SendNUIMessage(ctx)
end
RegisterNetEvent("SEND_CEF_MESSAGE", SendCefMessage)