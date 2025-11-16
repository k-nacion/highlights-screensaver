local json = require("json")
local utils = require("utils")

local M = {}

---@class Clipping
---@field text string
---@field note string|nil
---@field created_at string
---@field source_title string
---@field source_author string|nil
---@field enabled boolean
M.Clipping = {}
M.Clipping.__index = M.Clipping

---@param text string
---@param note string|nil
---@param created_at string
---@param source_title string
---@param source_author string|nil
---@param enabled boolean
---@return Clipping
function M.Clipping.new(text, note, created_at, source_title, source_author, enabled)
	local self = setmetatable({}, M.Clipping)
	self.text = text
	self.note = note
	self.created_at = created_at
	self.source_title = source_title
	self.source_author = source_author
	self.enabled = enabled
	return self
end

---@param self Clipping
---@return string
function M.Clipping:filename()
	return utils.normalise(self.source_title .. " " .. self.created_at .. ".json")
end

---@param path string
---@return Clipping[]
function M.extractClippingsFromSidecar(path)
	local metadata = dofile(path .. "/metadata.epub.lua")
	local authors = metadata.stats.authors
	local title = metadata.stats.title
	local clippings = {}

	for _, annotation in ipairs(metadata.annotations) do
		local clipping =
			M.Clipping.new(annotation.text, annotation.note or nil, annotation.datetime, title, authors, true)
		table.insert(clippings, clipping)
	end

	return clippings
end

---@param clipping Clipping
function M.saveClipping(clipping)
	utils.makeDir(utils.getClippingsDir())
	local path = utils.getClippingsDir() .. "/" .. clipping:filename()
	local file, err = io.open(path, "w")
	if not file then
		error("Error opening clippings file: " .. path .. ". Error: " .. tostring(err))
	end

	local content = json.encode(clipping, { indent = true })
	file:write(content)
	file:close()
end

---@return Clipping
function M.getRandomClipping()
	local clipping = M.Clipping.new(
		"The chief financial officer at Lucasfilm found Jobs arrogant and prickly, so when it came time to hold a meeting of all the players, he told Catmull, “We have to establish the right pecking order.” The plan was to gather everyone in a room with Jobs, and then the CFO would come in a few minutes late to establish that he was the person running the meeting. “But a funny thing happened,” Catmull recalled. “Steve started the meeting on time without the CFO, and by the time the CFO walked in Steve was already in control of the meeting.”",
		"Pretend to be completely in control, and people will assume that you are.",
		"2025-11-12 00:19:09",
		"Steve Jobs",
		"Walter Isaacson",
		true
	)
	return clipping
end

return M
