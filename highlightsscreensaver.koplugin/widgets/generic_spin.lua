local UIManager = require("ui/uimanager")
local SpinWidget = require("ui/widget/spinwidget")

return function(opts)
    UIManager:show(SpinWidget:new{
        title_text = opts.title,
        value = opts.value,
        value_min = opts.min,
        value_max = opts.max,
        step = opts.step or 1,
        default_value = opts.default,
        callback = function(spin)
            if opts.onApply then
                opts.onApply(spin.value)
            end
        end,
    })
end
