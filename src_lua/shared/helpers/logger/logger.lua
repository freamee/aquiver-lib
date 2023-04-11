local Logger = {}

---@param content any
---@param toJSON? boolean
function Logger:debug(content, toJSON)
    local f = ""
    f = "->" .. " ^3"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:error(content, toJSON)
    local f = ""
    f = "->" .. " ^1"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

---@param content any
---@param toJSON? boolean
function Logger:info(content, toJSON)
    local f = ""
    f = "->" .. " ^5"

    content = toJSON and json.encode(content, { indent = true }) or content

    f = f .. content

    print(f)
end

return Logger
