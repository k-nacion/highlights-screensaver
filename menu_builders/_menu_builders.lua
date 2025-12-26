-- lua
local _ = require("gettext")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")

-- Individual menu modules
local scanMenus = require("menu_builders.scan")
local fontsMenus = require("menu_builders.fonts_menu")
local themeMenus = require("menu_builders.theme")
local highlightsMenus = require("menu_builders.highlights_layout")
local notesMenus = require("menu_builders.notes_menu")
local importMenus = require("menu_builders.import_quotes_menu")
local orientationMenus = require("menu_builders.orientation_menu")
local disableHighlightMenus = require("menu_builders.disable_highlight_menu")
local notesLayoutMenus = require("menu_builders.notes_layout")

-- Constants
local HIGHLIGHTS_MODE = "highlights"

-------------------------------------------------------------------------
-- PATCH `dofile` TO INJECT MENUS
-------------------------------------------------------------------------

local function patchDofileMenus()
    local orig_dofile = dofile
    _G.dofile = function(filepath)
        local result = orig_dofile(filepath)

        if filepath and filepath:match("screensaver_menu%.lua$") then
            if result and result[1] and result[1].sub_item_table then
                local wallpaper_submenu = result[1].sub_item_table

                -- Add highlights screensaver menu
                table.insert(result, 3, {
                    text = _("Highlights screensaver"),
                    sub_item_table = {
                        scanMenus.buildMenuScanHighlights(),
                        scanMenus.buildMenuAddScannableDirectory(),
                        disableHighlightMenus.buildMenuDisableHighlight(),
                        themeMenus.buildMenuTheme(),
                        fontsMenus.buildMenuFonts(),
                        highlightsMenus.buildMenuHighlightsLayoutOptions(),
                        notesLayoutMenus.buildMenuNotesLayoutOptions(),
                        orientationMenus.buildMenuToggleOrientation(),
                        notesMenus.buildMenuShowNotesOption(),
                        importMenus.buildMenuImportExternalQuotes(),
                    },
                })

                -- Add option to select highlights screensaver
                table.insert(wallpaper_submenu, 6, {
                    text = _("Show highlights screensaver"),
                    radio = true,
                    checked_func = function()
                        return G_reader_settings:readSetting("screensaver_type") == HIGHLIGHTS_MODE
                    end,
                    callback = function()
                        G_reader_settings:saveSetting("screensaver_type", HIGHLIGHTS_MODE)
                    end,
                })
            end
        end

        return result
    end
end

-------------------------------------------------------------------------
-- EXPORT
-------------------------------------------------------------------------

return {
    patchDofileMenus = patchDofileMenus,
}
