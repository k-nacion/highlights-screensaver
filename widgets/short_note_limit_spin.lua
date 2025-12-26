local UIManager = require("ui/uimanager")
local _ = require("gettext")

local function showShortNoteLimitSpin(current_value, onApply)
    local SpinWidget = require("ui/widget/spinwidget")

    UIManager:show(SpinWidget:new{
        title_text = _("Character limit for short notes"),
        value = current_value or 70,
        value_min = 10,
        value_max = 500,
        default_value = 70,

        callback = function(spin)
            G_reader_settings:saveSetting("show_notes_limit", spin.value)
            G_reader_settings:flush()

            if onApply then
                onApply(spin.value)
            end
        end,
    })
end

return showShortNoteLimitSpin
