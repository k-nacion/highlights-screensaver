--[[--
Show a random highlight on your screensaver.

@module koplugin.HighlightScreensaver
--]]
--
--
local Dispatcher = require("dispatcher") -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Screensaver = require("ui/screensaver")
local _ = require("gettext")

local HighlightScreensaver = WidgetContainer:extend({
    name = "Highlight Screensaver",
    is_doc_only = false,
})

function HighlightScreensaver:init()
    self.ui.menu:registerToMainMenu(self)
end

function HighlightScreensaver:addToMainMenu(menu_items)
    menu_items.highlight_screensaver = {
        text = _("Highlight Screensaver"),
        -- in which menu this should be appended
        sorting_hint = "tools",
        sub_item_table = {
            {
                text = _("Scan all book highlights"),
                -- a callback when tapping
                callback = function()
                    self:scanHighlights()
                end,
            },
            {
                text = _("Add to scannable directories"),
                callback = function()
                    self:addToScannableDirectories()
                end,
            },
        },
    }
end

function HighlightScreensaver:scanHighlights()
    local popup = InfoMessage:new({
        text = _("Highlight Screensaver popup"),
    })
    UIManager:show(popup)
end

function HighlightScreensaver:addToScannableDirectories()
    local popup = InfoMessage:new({
        text = _("Add to scannable dirs"),
    })
    UIManager:show(popup)
end

return HighlightScreensaver
