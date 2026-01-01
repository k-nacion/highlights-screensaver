local _ = require("gettext")

-------------------------------------------------------------------------
-- ORIENTATION MENU
-------------------------------------------------------------------------

-- Explicit constants (VERY important)
local ORIENT_DEFAULT   = "default"
local ORIENT_PORTRAIT  = "portrait"
local ORIENT_LANDSCAPE = "landscape"

local function getOrientationLabel()
	local value = G_reader_settings:readSetting("highlights_orientation") or ORIENT_DEFAULT

	if value == ORIENT_PORTRAIT then
		return _("Portrait")
	elseif value == ORIENT_LANDSCAPE then
		return _("Landscape")
	else
		return _("Current Book")
	end
end

local function buildMenuToggleOrientation()
	return {
		text_func = function()
			return _("Orientation: ") .. getOrientationLabel()
		end,
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
		separator = true,
	}
end

return {
	buildMenuToggleOrientation = buildMenuToggleOrientation
}
