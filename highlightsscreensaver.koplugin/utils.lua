local Device = require("device")
local lfs = require("libs/libkoreader-lfs")

local M = {}

---@return string
function M.getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

---@return string
function M.getPluginDir()
	return M.getDefaultRootDir() .. "/onboard/highlight-screensaver"
end

---@return string
function M.getClippingsDir()
	return M.getPluginDir() .. "/clippings"
end

---@param path string
function M.makeDir(path)
	local current = ""
	for dir in path:gmatch("[^/]+") do
		current = current .. "/" .. dir
		local attr = lfs.attributes(current, "mode")
		if not attr then
			local ok, err = lfs.mkdir(current)
			if not ok then
				return nil, "Failed to create directory '" .. current .. "': " .. err
			end
		end
	end
	return true
end

---@return string
function M.getLastScannedDateFilePath()
	return M.getPluginDir() .. "/last-scanned.txt"
end

---@return string|nil
function M.getLastScannedDate()
	local file = io.open(M.getLastScannedDateFilePath(), "r")
	local contents = file and file:read("*a") or nil
	if file then
		file:close()
	end
	return contents
end

---@return string
function M.getLastShownHighlightPath()
	return M.getPluginDir() .. "/last-shown-highlight.txt"
end

---@return string|nil
function M.getLastShownHighlightFileName()
	local file = io.open(M.getLastShownHighlightPath(), "r")
	local contents = file and file:read("*a") or nil
	if file then
		file:close()
	end
	return contents
end

function M.setLastShownHighlight(clipping)
	M.makeDir(M.getPluginDir())
	local file = assert(io.open(M.getLastShownHighlightPath(), "w"))
	local content = clipping:filename()
	file:write(content)
	file:close()
end

---@param s string
---@return string
function M.normalise(s)
	s = s:match("^%s*(.-)%s*$") -- trim
	s = s:lower()
	s = s:gsub("%s+", "_")    -- replace spaces for underscores
	s = s:gsub("[^%w_%-%.]", "") -- remove unsafe filename chars
	return s
end

return M
