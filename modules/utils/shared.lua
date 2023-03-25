local Module <const> = {}

Shared.Utils = Module

---@param content any
---@param toJSON? boolean
function Module.Debug(content, toJSON)
    local f = ""
    f = "->" .. " ^3"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Module.Error(content, toJSON)
    local f = ""
    f = "->" .. " ^1"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Module.Info(content, toJSON)
    local f = ""
    f = "->" .. " ^5"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

function Module.RoundNumber(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Dereferencing a value. (probably item)
---@generic T
---@param a T
---@return T
function Module.dereference(a)
    return json.decode(json.encode(a))
end
