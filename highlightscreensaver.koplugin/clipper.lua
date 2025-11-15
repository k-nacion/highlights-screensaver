local utils = require("utils")

local M = {}

---@class Clipping
---@field text string
---@field note string|nil
---@field created_at string
---@field source_title string
---@field source_author string|nil
local Clipping = {}
Clipping.__index = Clipping

---@param self Clipping
function Clipping:filename()
	return utils.normalise(self.source_title .. " " .. self.created_at)
end

return M
