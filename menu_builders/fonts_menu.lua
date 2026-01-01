local _ = require("gettext")
local FontList = require("fontlist")

local config = require("core.config")
local util = require("util")

local function buildMenuFonts()
    local all_fonts = FontList:getFontList()
    local curr_fonts = config.getFonts()

    local function buildFontSubmenu(display_name, font_key)
        local submenu = {
            text_func = function() return display_name .. ": " .. curr_fonts[font_key] end,
            sub_item_table = {}
        }

        for _, font_path in ipairs(all_fonts) do
            local _, font_filename = util.splitFilePathName(font_path)
            table.insert(submenu.sub_item_table, {
                text = font_filename,
                callback = function()
                    curr_fonts[font_key] = font_filename
                    config.setFonts(curr_fonts)
                end,
                checked_func = function()
                    return font_filename == curr_fonts[font_key]
                end,
            })
        end

        return submenu
    end

    return {
        text = _("Fonts"),
        sub_item_table = {
            buildFontSubmenu("Quote", "quote"),
            buildFontSubmenu("Author", "author"),
            buildFontSubmenu("Note", "note"),
        },
    }
end

return {
    buildMenuFonts = buildMenuFonts
}
