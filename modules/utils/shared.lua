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

local RunningThreads = {}

---@param callback function
---@param timeout number
function Module.Thread(callback, timeout)
    ---@class ThreadClass
    ---@field running boolean
    ---@field callback function
    ---@field timeout number
    ---@field id number
    local self = {}

    self.callback = callback
    self.timeout = timeout
    self.id = nil
    self.running = false

    self.start = function()
        if not self.running then
            self.running = true

            Citizen.CreateThreadNow(function(threadID)
                self.id = threadID

                RunningThreads[self.id] = self

                repeat
                    Citizen.Wait(self.timeout)
                    self.callback()
                until not self.running

                self.running = false
                RunningThreads[self.id] = nil
            end)
        end
    end

    self.stop = function()
        self.running = false
    end

    return self
end
