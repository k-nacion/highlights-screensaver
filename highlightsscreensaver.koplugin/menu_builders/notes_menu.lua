local _ = require("gettext")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local ffiUtil = require("ffi/util")
local T = ffiUtil.template

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
					local showShortNoteLimitSpin =
						require("widgets/short_note_limit_spin")

					showShortNoteLimitSpin(
						G_reader_settings:readSetting("show_notes_limit") or 70,
						function()
							touchmenu_instance:updateItems()
						end
					)
				end,
			},
		},
	}
end

return { buildMenuShowNotesOption = buildMenuShowNotesOption }
