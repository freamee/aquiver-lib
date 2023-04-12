local Helpers = {}

---@param x number
---@param y number
---@param z number
---@param text string
---@param size? number Default: 0.25
---@param font? number Default: 0
function Helpers:drawText3D(x, y, z, text, size, font)
    size = type(size) == "number" and size or 0.25
    font = type(font) == "number" and font or 0

    SetTextScale(size, size)
    SetTextFont(font)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 100)
    -- SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param x number
---@param y number
---@param text string
---@param size? number Default: 0.25
---@param font? number Default: 0
function Helpers:drawText2D(x, y, text, size, font)
    size = type(size) == "number" and size or 0.25
    font = type(font) == "number" and font or 0

    SetTextFont(font)
    SetTextProportional(false)
    SetTextScale(size, size)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 100)
    SetTextDropShadow()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

return Helpers
