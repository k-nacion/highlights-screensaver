local _ = require("gettext")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local ffiUtil = require("ffi/util")
local T = ffiUtil.template

-- Ensure default values exist
if not G_reader_settings:readSetting("show_highlight_notes_option") then
	G_reader_settings:saveSetting("show_highlight_notes_option", "full")
end

if not G_reader_settings:readSetting("show_highlight_notes_limit") then
	G_reader_settings:saveSetting("show_highlight_notes_limit", 70)
end

-- Helper: capitalize first letter
local function capitalizeFirstLetter(str)
	return str:gsub("^%l", string.upper)
end

-------------------------------------------------------------------------
-- SHOW HIGHLIGHT NOTES MENU
-------------------------------------------------------------------------

local function buildMenuShowHighlightNotes()
	return {
		text_func = function()
			local current_state = G_reader_settings:readSetting("show_highlight_notes_option") or "full"
			return T(_("Show Highlight's Notes: %1"), capitalizeFirstLetter(current_state))
		end,
		sub_item_table = {
			{
				text = _("Disable"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_highlight_notes_option") == "disable"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_highlight_notes_option", "disable")
				end,
			},
			{
				text = _("Full"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_highlight_notes_option") == "full"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_highlight_notes_option", "full")
				end,
			},
			{
				text = _("Short"),
				radio = true,
				checked_func = function()
					return G_reader_settings:readSetting("show_highlight_notes_option") == "short"
				end,
				callback = function()
					G_reader_settings:saveSetting("show_highlight_notes_option", "short")
				end,
			},
			{
				text_func = function()
					return T(
							_("Character limit for short notes: %1"),
							G_reader_settings:readSetting("show_highlight_notes_limit") or 70
					)
				end,
				enabled_func = function()
					return G_reader_settings:readSetting("show_highlight_notes_option") == "short"
				end,
				keep_menu_open = true,
				callback = function(touchmenu_instance)
					local showShortNoteLimitSpin =
					require("widgets/short_note_limit_spin")

					showShortNoteLimitSpin(
							G_reader_settings:readSetting("show_highlight_notes_limit") or 70,
							function()
								touchmenu_instance:updateItems()
							end
					)
				end,
			},
		},
	}
end

return { buildMenuShowHighlightNotes = buildMenuShowHighlightNotes }
