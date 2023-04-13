local Logger = {}

---@param content any
---@param toJSON? boolean
function Logger:debug(content, toJSON)
    local f = ""
    f = string.format("[%s] -> ^3", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:error(content, toJSON)
    local f = ""
    f = string.format("[%s] -> ^1", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:info(content, toJSON)
    local f = ""
    f = string.format("[%s] -> ^5", _G.APIShared.resource)

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

return Logger
