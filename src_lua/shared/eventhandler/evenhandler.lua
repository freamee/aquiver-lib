---@class EventHandler
---@field events table<string, fun(...)[]>
local EventHandler = {}
EventHandler.__index = EventHandler

EventHandler.new = function()
    local self = setmetatable({}, EventHandler)

    self.events = {}

    return self
end

---@param eventName string
---@param cb fun(...)
function EventHandler:AddEvent(eventName, cb)
    if type(self.events[eventName]) ~= "table" then
        self.events[eventName] = {}
    end

    self.events[eventName][#self.events[eventName] + 1] = cb
end

---@param eventName string
---@param ... any
function EventHandler:TriggerEvent(eventName, ...)
    if type(self.events[eventName]) ~= "table" then return end

    for i = 1, #self.events[eventName] do
        self.events[eventName][i](...)
    end
end

return EventHandler
