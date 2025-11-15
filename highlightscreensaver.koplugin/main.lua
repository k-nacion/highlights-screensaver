--[[--
Show a random highlight on your screensaver.

@module koplugin.HighlightScreensaver
--]]
--
--
local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local _ = require("gettext")
local Device = require("device")
local lfs = require("libs/libkoreader-lfs")

local HighlightScreensaver = WidgetContainer:extend({
	name = "Highlight Screensaver",
	is_doc_only = false,
})

function HighlightScreensaver:init()
	self.ui.menu:registerToMainMenu(self)
end

function HighlightScreensaver:addToMainMenu(menu_items)
	menu_items.highlight_screensaver = {
		text = _("Highlight Screensaver"),
		-- in which menu this should be appended
		sorting_hint = "tools",
		sub_item_table = {
			{
				text = _("Scan all book highlights"),
				-- a callback when tapping
				callback = function()
					self:scanHighlights()
				end,
			},
			{
				text = _("Add to scannable directories"),
				callback = function()
					self:addToScannableDirectories()
				end,
			},
		},
	}
end

function HighlightScreensaver:scanHighlights()
	local popup = InfoMessage:new({
		text = _("Highlight Screensaver popup"),
	})
	UIManager:show(popup)
end

local function getDefaultRootDir()
	if Device:isCervantes() or Device:isKobo() then
		return "/mnt"
	elseif Device:isEmulator() then
		return lfs.currentdir()
	else
		return Device.home_dir or lfs.currentdir()
	end
end

local function getPluginDir()
	return getDefaultRootDir() .. "/onboard/highlight-screensaver"
end

function HighlightScreensaver:addToScannableDirectories()
	-- local dirsFile = io.open(getPluginDir() .. "/scannable-dirs.json", "w")
	local popup = InfoMessage:new({
		text = _(getPluginDir()),
	})
	UIManager:show(popup)
end

return HighlightScreensaver
