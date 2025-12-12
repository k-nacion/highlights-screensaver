local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local Device = require("device")
local Screen = Device.screen
local _ = require("gettext")
local highlightsWidget = require("highlights_widget")
local scan = require("scan")
local clipper = require("clipper")
local config = require("config")
local ffiUtil = require("ffi/util")
local T = ffiUtil.template
local BD = require("document/credocument"):engineInit()
local FontList = require("fontlist")
local Font = require("ui/font")

-------------------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------------------

local HIGHLIGHTS_MODE = "highlights"

local ORIENT_DEFAULT = "default"
local ORIENT_PORTRAIT = "portrait"
local ORIENT_LANDSCAPE = "landscape"

local ROT_UPRIGHT = Screen.DEVICE_ROTATED_UPRIGHT or 0
local ROT_LEFT    = Screen.DEVICE_ROTATED_LEFT    or 1
local ROT_DOWN    = Screen.DEVICE_ROTATED_DOWN    or 2
local ROT_RIGHT   = Screen.DEVICE_ROTATED_RIGHT   or 3

-------------------------------------------------------------------------
-- MENU BUILDERS
-------------------------------------------------------------------------

local function buildMenuScanHighlights()
	return {
		text = _("Scan book highlights"),
		callback = function()
			scan.scanHighlights()
			UIManager:show(InfoMessage:new({
				text = _("Finished scanning highlights"),
			}))
		end,
	}
end

local function buildMenuAddScannableDirectory()
	return {
		text = _("Add current directory to scannable directories"),
		callback = function()
			scan.addToScannableDirectories()
		end,
	}
end

local function buildMenuDisableHighlight()
	return {
		text = _("Disable last shown highlight"),
		callback = function()
			local fname = config.getLastShownHighlight()
			if not fname then return end

			local clipping = clipper.getClipping(fname)
			if not clipping then return end

			clipping.enabled = false
			clipper.saveClipping(clipping)

			UIManager:show(InfoMessage:new({
				text = _("Disabled highlight: " .. clipping:filename()),
			}))
		end,
	}
end

local function buildMenuTheme()
	local dark = {
		text = _("Dark"),
		radio = true,
		checked_func = function()
			return config.getTheme() == config.Theme.DARK
		end,
		callback = function()
			config.setTheme(config.Theme.DARK)
		end,
	}
	local light = {
		text = _("Light"),
		radio = true,
		checked_func = function()
			return config.getTheme() == config.Theme.LIGHT
		end,
		callback = function()
			config.setTheme(config.Theme.LIGHT)
		end,
	}
	return {
		text_func = function()
			local theme = config.getTheme()
			local theme_name = theme:sub(1, 1):upper() .. theme:sub(2)
			return T(_("Theme: %1"), _(theme_name))
		end,
		sub_item_table = { dark, light },
	}
end

local function buildMenuFonts()
	local all_fonts = FontList:getFontList()
	local curr_fonts = config.getFonts()

	local function buildFontSubmenu(display_name, font_key)
		local submenu = {
			text_func = function()
				return display_name .. ": " .. curr_fonts[font_key]
			end,
			sub_item_table = {},
		}

		for _, font_path in ipairs(all_fonts) do
			local _, font_filename = require("util").splitFilePathName(font_path)
			table.insert(submenu.sub_item_table, {
				text = font_filename,
				callback = function()
					curr_fonts[font_key] = font_filename
					config.setFonts(curr_fonts)
				end,
				checked_func = function()
					return font_filename == curr_fonts[font_key]
				end,
			})
		end

		return submenu
	end

	return {
		text = _("Fonts"),
		sub_item_table = {
			buildFontSubmenu("Quote", "quote"),
			buildFontSubmenu("Author", "author"),
			buildFontSubmenu("Note", "note"),
		},
	}
end

-------------------------------------------------------------------------
-- NEW: ORIENTATION MENU BUILDER
-------------------------------------------------------------------------

local function buildMenuToggleOrientation()
	return {
		text = _("Toggle Orientation"),
		sub_item_table = {
			{
				text = _("Current Book Orientation"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("highlights_orientation") == ORIENT_DEFAULT
				end,
				callback = function()
					G_reader_settings:saveSetting("highlights_orientation", ORIENT_DEFAULT)
				end,
			},
			{
				text = _("Portrait"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("highlights_orientation") == ORIENT_PORTRAIT
				end,
				callback = function()
					G_reader_settings:saveSetting("highlights_orientation", ORIENT_PORTRAIT)
				end,
			},
			{
				text = _("Landscape"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("highlights_orientation") == ORIENT_LANDSCAPE
				end,
				callback = function()
					G_reader_settings:saveSetting("highlights_orientation", ORIENT_LANDSCAPE)
				end,
			},
		},
	}
end

-------------------------------------------------------------------------
-- NEW: SHOW NOTES OPTION MENU BUILDER
-------------------------------------------------------------------------

local function buildMenuShowNotesOption()
	return {
		text = _("Show Notes Option"),
		sub_item_table = {
			{
				text = _("Disable"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_notes_option") == "disable"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_notes_option", "disable")
					UIManager:show(InfoMessage:new({ text = _("Notes disabled") }))
				end,
			},
			{
				text = _("Full"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_notes_option") == "full"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_notes_option", "full")
					UIManager:show(InfoMessage:new({ text = _("Showing full notes") }))
				end,
			},
			{
				text = _("Short"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_notes_option") == "short"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_notes_option", "short")
					UIManager:show(InfoMessage:new({ text = _("Notes shortened") }))
				end,
			},
		}
	}
end





-------------------------------------------------------------------------
-- PATCH `dofile` TO INJECT MENU
-------------------------------------------------------------------------

local orig_dofile = dofile
_G.dofile = function(filepath)
	local result = orig_dofile(filepath)

	if filepath and filepath:match("screensaver_menu%.lua$") then
		if result and result[1] and result[1].sub_item_table then
			local wallpaper_submenu = result[1].sub_item_table

			-- Insert our highlight screensaver settings
			table.insert(result, 3, {
				text = _("Highlights screensaver"),
				sub_item_table = {
					buildMenuScanHighlights(),
					buildMenuAddScannableDirectory(),
					buildMenuDisableHighlight(),
					buildMenuTheme(),
					buildMenuFonts(),
					buildMenuToggleOrientation(),

					-- ADDED: Show Notes Option
					buildMenuShowNotesOption(),
				},
			})

			-- Insert the radio button selector under the wallpaper menu
			table.insert(wallpaper_submenu, 6, {
				text = _("Show highlights screensaver"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("screensaver_type") == HIGHLIGHTS_MODE
				end,
				callback = function()
					G_reader_settings:saveSetting("screensaver_type", HIGHLIGHTS_MODE)
				end,
			})
		end
	end

	return result
end

-------------------------------------------------------------------------
-- PATCH THE SCREENSAVER SHOW FUNCTION
-------------------------------------------------------------------------

local og_screensaver_show = Screensaver.show
Screensaver.show = function(self)
	if self.screensaver_type == HIGHLIGHTS_MODE then

		if self.screensaver_widget then
			UIManager:close(self.screensaver_widget)
			self.screensaver_widget = nil
		end

		Device.screen_saver_mode = true

		local mode = G_reader_settings:readSetting("highlights_orientation") or ORIENT_DEFAULT
		local current = Screen:getRotationMode()
		Device.orig_rotation_mode = current

		if mode == ORIENT_DEFAULT then
			Device.orig_rotation_mode = nil
		elseif mode == ORIENT_PORTRAIT then
			Screen:setRotationMode(ROT_UPRIGHT)
		elseif mode == ORIENT_LANDSCAPE then
			Screen:setRotationMode(ROT_LEFT)
		end

		local last_scanned = config.getLastScannedDate()
		local t = os.date("*t")
		local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
		if not last_scanned or last_scanned < today then
			scan.scanHighlights()
		end

		local clipping = clipper.getRandomClipping()
		config.setLastShownHighlight(clipping:filename())

		self.screensaver_widget =
			highlightsWidget.buildHighlightsScreensaverWidget(clipping)
		self.screensaver_widget.modal = true
		self.screensaver_widget.dithered = true
		UIManager:show(self.screensaver_widget, "full")

		return
	end

	og_screensaver_show(self)
end

-------------------------------------------------------------------------
-- PLUGIN WRAPPER
-------------------------------------------------------------------------

local HighlightsScreensaver = WidgetContainer:extend({
	name = "Highlights Screensaver",
	is_doc_only = false,
})

function HighlightsScreensaver:init() end

return HighlightsScreensaver


