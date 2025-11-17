local _ = require("gettext")
local FileManager = require("apps/filemanager/filemanager")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")

local clipper = require("clipper")
local config = require("config")
local utils = require("utils")

local M = {}

function M.scanHighlights()
	utils.makeDir(utils.getPluginDir())
	local conf = config.load()

	local sidecars = utils.getAllSidecarPaths(conf.scannable_directories)
	for _, sidecar in ipairs(sidecars) do
		local clippings = clipper.extractClippingsFromSidecar(sidecar)
		for _, clipping in ipairs(clippings) do
			local existingClipping = clipper.getClipping(clipping:filename())
			if existingClipping then
				clipping.enabled = existingClipping.enabled
			end
			clipper.saveClipping(clipping)
		end
	end

	local file = assert(io.open(utils.getLastScannedDateFilePath(), "w"))
	local t = os.date("*t")
	local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
	file:write(today)
	file:close()
end

function M.addToScannableDirectories()
	local conf = config.load()
	local curr_dir = FileManager.instance.file_chooser.path
	table.insert(conf.scannable_directories, curr_dir)

	local unique_dirs = {}
	local seen = {}
	for _, dir in ipairs(conf.scannable_directories) do
		if not seen[dir] then
			table.insert(unique_dirs, dir)
			seen[dir] = true
		end
	end

	conf:save()
	local popup = InfoMessage:new({
		text = _("Added to scannable directories: " .. curr_dir),
	})
	UIManager:show(popup)
end

return M
