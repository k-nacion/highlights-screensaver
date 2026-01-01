--
local _ = require("gettext")
local Screensaver = require("ui/screensaver")

local Spin = require("widgets.generic_spin")
local K = require("core.keys")
local config = require("core.config")

------------------------------------------------------------
-- Padding / Margin (ALL sides only)
------------------------------------------------------------
local function buildMenuPaddingMargin()
    return {
        text = _("Padding / Margin"),
        sub_item_table = {

            -- Padding (All)
            {
                text_func = function()
                    local v = config.read(K.screensaver_message.layout.padding) or 16
                    return _("Padding: ") .. v
                end,
                keep_menu_open = true,
                callback = function(touchmenu)
                    Spin {
                        value = config.read(K.screensaver_message.layout.padding) or 16,
                        min = 0,
                        max = 64,
                        step = 2,
                        default = 16,
                        onApply = function(v)
                            config.write(K.screensaver_message.layout.padding, v)
                            touchmenu:updateItems()
                        end,
                    }
                end,
            },

            -- Margin (All)
            {
                text_func = function()
                    local v = config.read(K.screensaver_message.layout.margin) or 24
                    return _("Margin: ") .. v
                end,
                keep_menu_open = true,
                callback = function(touchmenu)
                    Spin {
                        value = config.read(K.screensaver_message.layout.margin) or 24,
                        min = 0,
                        max = 64,
                        step = 2,
                        default = 24,
                        onApply = function(v)
                            config.write(K.screensaver_message.layout.margin, v)
                            touchmenu:updateItems()
                        end,
                    }
                end,
            },
        },
    }
end

------------------------------------------------------------
-- Alignment
------------------------------------------------------------
local function buildMenuAlignment()
    return {
        text = _("Alignment"),
        sub_item_table = {
            {
                text = _("Left"),
                radio = true,
                checked_func = function()
                    return config.read(K.screensaver_message.layout.alignment) == "left"
                end,
                callback = function()
                    config.write(K.screensaver_message.layout.alignment, "left")
                end,
            },
            {
                text = _("Center"),
                radio = true,
                checked_func = function()
                    return config.read(K.screensaver_message.layout.alignment) == "center"
                end,
                callback = function()
                    config.write(K.screensaver_message.layout.alignment, "center")
                end,
            },
            {
                text = _("Right"),
                radio = true,
                checked_func = function()
                    return config.read(K.screensaver_message.layout.alignment) == "right"
                end,
                callback = function()
                    config.write(K.screensaver_message.layout.alignment, "right")
                end,
            },
        },
    }
end

------------------------------------------------------------
-- Line spacing
------------------------------------------------------------
local function buildMenuLineSpacing()
    return {
        text_func = function()
            local value = config.read(K.screensaver_message.layout.line_spacing) or 1.2
            return _("Line Spacing: ") .. string.format("%.2f", value)
        end,
        keep_menu_open = true,
        callback = function(touchmenu)
            Spin {
                value = config.read(K.screensaver_message.layout.line_spacing) or 1.2,
                min = 0.6,
                max = 2.0,
                step = 0.05,
                onApply = function(v)
                    config.write(K.screensaver_message.layout.line_spacing, v)
                    touchmenu:updateItems()
                end,
            }
        end,
    }
end

------------------------------------------------------------
-- Font size
------------------------------------------------------------
local function buildMenuFontSize()
    return {
        text_func = function()
            local value = config.read(K.screensaver_message.layout.font_size) or 48
            return _("Font Size: ") .. value
        end,
        keep_menu_open = true,
        callback = function(touchmenu)
            Spin {
                value = config.read(K.screensaver_message.layout.font_size) or 48,
                min = 12,
                max = 72,
                step = 2,
                onApply = function(v)
                    config.write(K.screensaver_message.layout.font_size, v)
                    touchmenu:updateItems()
                end,
            }
        end,
    }
end

------------------------------------------------------------
-- Layout menu
------------------------------------------------------------
local function buildMenuSleepScreenMessageLayout()
    return {
        text = _("Layout"),
        sub_item_table = {
            buildMenuAlignment(),
            buildMenuLineSpacing(),
            buildMenuFontSize(),
            buildMenuPaddingMargin(),
        },
    }
end

------------------------------------------------------------
-- Main Sleep Screen Message menu
------------------------------------------------------------
local function buildMenuSleepScreenMessageOptions()
    return {
        separator = true,
        text = _("Sleep Screen Message"),
        sub_item_table = {

            {
                text = _("Edit sleep screen message"),
                keep_menu_open = true,
                callback = function()
                    Screensaver:setMessage()
                end,
            },

            {
                text = _("Container Mode"),
                sub_item_table = {
                    {
                        text = _("Banner"),
                        radio = true,
                        checked_func = function()
                            return (config.read("screensaver_message_container") or "banner") == "banner"
                        end,
                        callback = function()
                            config.write("screensaver_message_container", "banner")
                        end,
                    },
                    {
                        text = _("Box"),
                        radio = true,
                        checked_func = function()
                            return config.read("screensaver_message_container") == "box"
                        end,
                        callback = function()
                            config.write("screensaver_message_container", "box")
                        end,
                    },
                },
            },

            {
                text = _("Width Mode"),
                sub_item_table = {
                    {
                        text = _("Viewport"),
                        radio = true,
                        checked_func = function()
                            return G_reader_settings:readSetting("screensaver_message_width_mode") == "viewport"
                        end,
                        callback = function()
                            G_reader_settings:saveSetting("screensaver_message_width_mode", "viewport")
                        end,
                    },
                    {
                        text = _("Message Content"),
                        radio = true,
                        checked_func = function()
                            return G_reader_settings:readSetting("screensaver_message_width_mode") == "message_content"
                        end,
                        callback = function()
                            G_reader_settings:saveSetting("screensaver_message_width_mode", "message_content")
                        end,
                    },
                    {
                        text = _("Highlight Width"),
                        radio = true,
                        checked_func = function()
                            return G_reader_settings:readSetting("screensaver_message_width_mode") == "highlight"
                        end,
                        callback = function()
                            G_reader_settings:saveSetting("screensaver_message_width_mode", "highlight")
                        end,
                    },
                    {
                        text_func = function()
                            local value = G_reader_settings:readSetting("screensaver_message_custom_width") or 200
                            return _("Custom Width: ") .. value
                        end,
                        radio = true,
                        checked_func = function()
                            return G_reader_settings:readSetting("screensaver_message_width_mode") == "custom"
                        end,
                        callback = function(touchmenu)
                            G_reader_settings:saveSetting("screensaver_message_width_mode", "custom")
                            Spin {
                                value = G_reader_settings:readSetting("screensaver_message_custom_width") or 200,
                                min = 50,
                                max = math.huge, -- UI freedom only
                                step = 10,
                                onApply = function(v)
                                    if v == math.huge or v ~= v then
                                        -- safety fallback
                                        v = 200
                                    end
                                    G_reader_settings:saveSetting("screensaver_message_custom_width", v)
                                    touchmenu:updateItems()
                                end,
                            }
                        end,
                    },
                },
            },

            buildMenuSleepScreenMessageLayout(),
        },
    }
end

return {
    buildMenuScreensaverMessageOptions = buildMenuSleepScreenMessageOptions,
}
