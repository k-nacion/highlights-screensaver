local _ = require("gettext")
local config = require("config")
local ffiUtil = require("ffi/util")
local T = ffiUtil.template


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

return {
    buildMenuTheme = buildMenuTheme,
}
