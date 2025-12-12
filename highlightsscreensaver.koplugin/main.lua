local WidgetContainer = require("ui/widget/container/widgetcontainer")
local menu_builders = require("menu_builders")
local screensaver_patch = require("screensaver_patch")

-- Patch Screensaver.show
screensaver_patch.patchScreensaverShow()

-- Patch dofile to inject menu
menu_builders.patchDofileMenus()

local HighlightsScreensaver = WidgetContainer:extend({
    name = "Highlights Screensaver",
    is_doc_only = false,
})

function HighlightsScreensaver:init() end

return HighlightsScreensaver
