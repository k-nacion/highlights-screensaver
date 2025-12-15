-- menu_builders.lua
local _ = require("gettext")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local scan = require("scan")
local clipper = require("clipper")
local config = require("config")
local FontList = require("fontlist")
local Font = require("ui/font")
local ffiUtil = require("ffi/util")
local T = ffiUtil.template


local Device = require("device")
local Screen = Device.screen

local HIGHLIGHTS_MODE = "highlights"
local ORIENT_DEFAULT = "default"
local ORIENT_PORTRAIT = "portrait"
local ORIENT_LANDSCAPE = "landscape"

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
        separator = true
	}
end

local function buildMenuTheme()
    local system_theme = {
        text = _("System"),
        radio = true,
        checked_func = function()
            return config.getTheme() == config.Theme.SYSTEM
        end,
        callback = function()
            config.setTheme(config.Theme.SYSTEM)
        end,
    }
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
            local theme_name = theme:sub(1,1):upper() .. theme:sub(2)
            return T(_("Theme: %1"), _(theme_name))
        end,
        sub_item_table = { system_theme, dark, light },  -- system is first
    }
end

local DirectoryScanner = require("widgets/directory_scanner")
local DirectoryPicker = require("widgets/directory_picker")

local function buildMenuImportExternalQuotes()
    return {
        text_func = function()
            local dir = config.getExternalQuotesDirectory()
            if not dir then
                return _("Import external quotes")
            end
            local folder_name = dir:match("([^/]+)$") or dir
            return _("External Quotes Location") .. ": " .. folder_name
        end,
        callback = function()
             DirectoryPicker.pickDirectory(function(dir_path)
				config.setExternalQuotesDirectory(dir_path) -- save last folder
				local externalQuotes = require("external_quotes")
				externalQuotes.importQuotes(dir_path)
			end)
        end,
        separator = true,
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
-- ORIENTATION MENU
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
        separator = true
	}
end

-------------------------------------------------------------------------
-- SHOW NOTES OPTION MENU
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
            {
                 text_func = function()
					return T(
						_("Character limit for short notes: %1"),
						G_reader_settings:readSetting("show_notes_limit") or 70
					)
				end,
				enabled_func = function()
					return G_reader_settings:readSetting("show_notes_option") == "short"
				end,
				keep_menu_open = true,
				callback = function(touchmenu_instance)
					local showShortNoteLimitSpin = require("widgets/short_note_limit_spin")

					showShortNoteLimitSpin(
						G_reader_settings:readSetting("show_notes_limit") or 70,
						function()
							touchmenu_instance:updateItems()
						end
					)
				end,
            },
		}
	}
end

-------------------------------------------------------------------------
-- PATCH `dofile` TO INJECT MENUS
-------------------------------------------------------------------------

local function patchDofileMenus()
	local orig_dofile = dofile
	_G.dofile = function(filepath)
		local result = orig_dofile(filepath)

		if filepath and filepath:match("screensaver_menu%.lua$") then
			if result and result[1] and result[1].sub_item_table then
				local wallpaper_submenu = result[1].sub_item_table

				table.insert(result, 3, {
					text = _("Highlights screensaver"),
					sub_item_table = {
                        buildMenuScanHighlights(),
                        buildMenuAddScannableDirectory(),
                        buildMenuDisableHighlight(),
                        buildMenuTheme(),
                        buildMenuFonts(),
                        buildMenuToggleOrientation(),
                        buildMenuShowNotesOption(),
						buildMenuImportExternalQuotes(),
                    },
				})

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
end

-------------------------------------------------------------------------
-- EXPORT
-------------------------------------------------------------------------

return {
	patchDofileMenus = patchDofileMenus,
}
