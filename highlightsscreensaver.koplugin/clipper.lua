local json = require("json")
local lfs = require("libs/libkoreader-lfs")
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
  local metadata_path
	for file in lfs.dir(path) do
		if file:match("^metadata%..-%.lua$") then
			metadata_path = path .. "/" .. file
			break
		end
	end
	local metadata = dofile(metadata_path)

	-- Safely read metadata.stats if it exists
	local stats = metadata.stats or {}

	-- Fall back to top-level fields if needed
	local authors = stats.authors or metadata.authors or "Unknown Author"
	local title = stats.title or metadata.title or "Untitled"

	local clippings = {}

	-- Safely read metadata.annotations if it exists
	local annotation_list = metadata.annotations or {}
	for _, annotation in ipairs(annotation_list) do

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

---@param filename string
---@return Clipping|nil
function M.getClipping(filename)
	local path = utils.getClippingsDir() .. "/" .. filename
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	local data = json.decode(content)
	return M.Clipping.new(data.text, data.note, data.created_at, data.source_title, data.source_author, data.enabled)
end

---@return Clipping
function M.getRandomClipping()
	local dir = utils.getClippingsDir()
	utils.makeDir(dir)

	math.randomseed(os.time())
	local chosenFile ---@type string|nil
	local count = 0

	-- reservoir sampling: https://en.wikipedia.org/wiki/Reservoir_sampling
	for file in lfs.dir(dir) do
		if file:match("%.json$") then
			local clipping = M.getClipping(file)
			if not clipping or not clipping.enabled then
				goto continue
			end

			count = count + 1
			if math.random(count) == 1 then
				chosenFile = file
			end
		end
		::continue::
	end

	local fallback_clipping = M.Clipping.new(
		"No highlights found. Ensure there there are valid scannable directories with books that contain highlights.",
		nil,
		"2025-11-12 00:19:09",
		"Highlights Screensaver",
		nil,
		true
	)
	if not chosenFile then
		return fallback_clipping
	end

	local clipping = M.getClipping(chosenFile)
	return clipping or fallback_clipping
end

return M