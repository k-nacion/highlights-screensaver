local WidgetContainer = require("ui/widget/container/widgetcontainer")
local menu_injector = require("menu_builders._menu_injector")
local screensaver_patch = require("core.screensaver_patch")

-- Patch Screensaver.show
screensaver_patch.patchScreensaverShow()

-- Patch dofile to inject menu
menu_injector.patchDofileMenus()

local HighlightsScreensaver = WidgetContainer:extend({
    name = "Highlights Screensaver",
    is_doc_only = false,
})

function HighlightsScreensaver:init() end

return HighlightsScreensaver
