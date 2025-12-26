-- utils.lua
local Device = require("device")
local lfs = require("libs/libkoreader-lfs")

local M = {}

function M.getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

function M.getPluginDir()
	return M.getDefaultRootDir() .. "/onboard/highlights-screensaver"
end

function M.getClippingsDir()
	return M.getPluginDir() .. "/clippings"
end

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

function M.normalise(s)
	s = s:match("^%s*(.-)%s*$") -- trim
	s = s:lower()
	s = s:gsub("%s+", "_") -- spaces → underscore
	s = s:gsub("[^%w_%-%.]", "") -- remove unsafe filename chars
	return s
end

return M
