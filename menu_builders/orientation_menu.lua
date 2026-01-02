local _ = require("gettext")
local keys = require("core.keys")
local config = require("core.config")
-------------------------------------------------------------------------
-- ORIENTATION MENU
-------------------------------------------------------------------------

-- Explicit constants (VERY important)
local ORIENT_DEFAULT   = "default"
local ORIENT_PORTRAIT  = "portrait"
local ORIENT_LANDSCAPE = "landscape"

local function getOrientationLabel()
	local value = config.read(keys.display.orientation) or ORIENT_DEFAULT

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
					return config.read(keys.display.orientation) == ORIENT_DEFAULT
				end,
				callback = function()
					config.write(keys.display.orientation, ORIENT_DEFAULT)
				end,
			},
			{
				text = _("Portrait"),
				radio = true,
				checked_func = function()
					return config.read(keys.display.orientation) == ORIENT_PORTRAIT
				end,
				callback = function()
					config.write(keys.display.orientation, ORIENT_PORTRAIT)
				end,
			},
			{
				text = _("Landscape"),
				radio = true,
				checked_func = function()
					return config.read(keys.display.orientation) == ORIENT_LANDSCAPE
				end,
				callback = function()
					config.write(keys.display.orientation, ORIENT_LANDSCAPE)
				end,
			},
		},
		separator = true,
	}
end

return {
	buildMenuToggleOrientation = buildMenuToggleOrientation
}
