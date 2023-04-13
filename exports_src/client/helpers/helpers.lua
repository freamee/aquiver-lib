local Helpers = {
    cached_res = {
        x = nil,
        y = nil
    },
    cached_texture_res = {}
}

---@private
function Helpers:cacheScreenResolution()
    if self.cached_res.x == nil or self.cached_res.y == nil then
        local rX, rY = GetActiveScreenResolution()
        self.cached_res = {
            x = rX,
            y = rY
        }
    end
end

---@private
function Helpers:cacheTextureResolution(textureDict, textureName)
    if not self.cached_texture_res[textureDict .. textureName] then
        local textureResolutionVector2 = GetTextureResolution(textureDict, textureName)

        self.cached_texture_res[textureDict .. textureName] = {
            x = textureResolutionVector2.x,
            y = textureResolutionVector2.y
        }
    end
end

---@private
function Helpers:getSpriteSize(scale, textureDict, textureName)
    return {
        scaleX = scale * self.cached_texture_res[textureDict .. textureName].x / self.cached_res.x,
        scaleY = scale * self.cached_texture_res[textureDict .. textureName].y / self.cached_res.y
    }
end

---@param d { screenX: number; screenY: number; textureDict: string; textureName:string; scale:number; rotation:number; r:number; g:number; b:number; a:number; }
---@async
function Helpers:drawSprite2D(d)
    RequestStreamedTextureDict(d.textureDict, false)
    while not HasStreamedTextureDictLoaded(d.textureDict) do
        Citizen.Wait(10)
    end

    self:cacheScreenResolution()
    self:cacheTextureResolution(d.textureDict, d.textureName)

    local size = self:getSpriteSize(d.scale, d.textureDict, d.textureName)

    DrawSprite(
        d.textureDict,
        d.textureName,
        d.screenX,
        d.screenY,
        size.scaleX,
        size.scaleY,
        d.rotation,
        d.r,
        d.g,
        d.b,
        d.a
    )
end

---@param d { x:number; y:number; z:number; textureDict:string; textureName:string; scale:number; r:number; g:number; b:number; a:number; }
---@async
function Helpers:drawSprite3D(d)
    RequestStreamedTextureDict(d.textureDict, false)
    while not HasStreamedTextureDictLoaded(d.textureDict) do
        Citizen.Wait(10)
    end

    self:cacheScreenResolution()
    self:cacheTextureResolution(d.textureDict, d.textureName)

    local size = self:getSpriteSize(d.scale, d.textureDict, d.textureName)
    local _, sX, sY = GetScreenCoordFromWorldCoord(d.x, d.y, d.z)

    DrawSprite(
        d.textureDict,
        d.textureName,
        sX,
        sY,
        size.scaleX,
        size.scaleY,
        0.0,
        d.r,
        d.g,
        d.b,
        d.a
    )
end

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
