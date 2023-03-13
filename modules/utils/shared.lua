local Module <const> = {}

Shared.Utils = Module

---@param content any
---@param toJSON? boolean
function Module:Debug(content, toJSON)
    local f = ""
    f = "[" .. self:GetResourceName() .. "]" .. "->" .. " ^3"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Module:Error(content, toJSON)
    local f = ""
    f = "[" .. self:GetResourceName() .. "]" .. "->" .. " ^1"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Module:Info(content, toJSON)
    local f = ""
    f = "[" .. self:GetResourceName() .. "]" .. "->" .. " ^5"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

function Module:RoundNumber(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Module:GetResourceName()
    return GetInvokingResource() or GetCurrentResourceName()
end