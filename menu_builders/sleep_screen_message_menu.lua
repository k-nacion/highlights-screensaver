local _ = require("gettext")

local function buildMenuSleepScreenMessageOptions()
    return {
        separator = true,
        text = _("Sleep Screen Message"),
        sub_item_table = {
            {
                text = _("Width: Viewport"),
                radio = true,
                checked_func = function()
                    return G_reader_settings:readSetting("screensaver_message_width_mode") == "viewport"
                end,
                callback = function()
                    G_reader_settings:saveSetting("screensaver_message_width_mode", "viewport")
                end,
            },
            {
                text = _("Width: Message Content"),
                radio = true,
                checked_func = function()
                    return G_reader_settings:readSetting("screensaver_message_width_mode") == "message_content"
                end,
                callback = function()
                    G_reader_settings:saveSetting("screensaver_message_width_mode", "message_content")
                end,
            },
            {
                text = _("Width: Highlight Width"),
                radio = true,
                checked_func = function()
                    return G_reader_settings:readSetting("screensaver_message_width_mode") == "highlight"
                end,
                callback = function()
                    G_reader_settings:saveSetting("screensaver_message_width_mode", "highlight")
                end,
            },
            {
                text = _("Width: Custom"),
                radio = true,
                checked_func = function()
                    return G_reader_settings:readSetting("screensaver_message_width_mode") == "custom"
                end,
                callback = function()
                    G_reader_settings:saveSetting("screensaver_message_width_mode", "custom")
                end,
            },
            -- Custom width spin remains the same
        }
    }
end

return {
    buildMenuScreensaverMessageOptions = buildMenuSleepScreenMessageOptions
}
