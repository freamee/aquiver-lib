---@class IHelp
---@field uid string
---@field msg string
---@field key? string
---@field image? string
---@field icon? string

---@class IMenuEntry
---@field name string
---@field icon string
---@field eventName string
---@field eventArgs? any

---@class IMenu
---@field header string
---@field menus IMenuEntry[]
