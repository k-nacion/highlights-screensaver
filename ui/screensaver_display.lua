local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Device = require("device")
local Screen = Device.screen
local ScreenSaverWidget = require("ui/widget/screensaverwidget")
local Size = require("ui/size")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local LineWidget = require("ui/widget/linewidget")
local FrameContainer = require("ui/widget/container/framecontainer")
local OverlapGroup = require("ui/widget/overlapgroup")
local BottomContainer = require("ui/widget/container/bottomcontainer")

local config = require("core.config")
local K = require("core.keys")

local M = {}

----------------------------------------------------------------
-- Defensive helpers
----------------------------------------------------------------
local function readNumber(key, default)
    local v = config.read(key, default)
    if type(v) ~= "number" then
        return default
    end
    return v
end

local function clamp(v, min, max)
    if v < min then
        return min
    end
    if v > max then
        return max
    end
    return v
end

----------------------------------------------------------------
-- Theme helpers
----------------------------------------------------------------
local function getThemeColors()
    local theme = config.getTheme()
    local is_night_mode = G_reader_settings:isTrue(K.koreader.is_night_mode) -- hybrid read example

    if theme == config.Theme.SYSTEM then
        return Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    elseif (theme == config.Theme.DARK and not is_night_mode)
            or (theme == config.Theme.LIGHT and is_night_mode) then
        return Blitbuffer.COLOR_WHITE, Blitbuffer.COLOR_BLACK
    else
        return Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    end
end

local function styleTextWidget(textw)
    local font_size = config.read(K.screensaver_message.layout.font_size)
    local line_height = config.read(K.screensaver_message.layout.line_spacing)
    local alignment = config.read(K.screensaver_message.layout.alignment) or "center"

    textw.line_height = line_height
    textw.alignment = alignment

    if textw.face and textw.face.family then
        textw.face = Font:getFace(textw.face.family, font_size)
    end

    return textw
end

----------------------------------------------------------------
-- Screensaver message containers
----------------------------------------------------------------
local function buildBoxMessage(textw)
    local textbw = styleTextWidget(textw)
    return FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        bordersize = Size.border.default,
        padding = readNumber(K.screensaver_message.layout.padding, Size.padding.large),
        margin = readNumber(K.screensaver_message.layout.margin, Size.margin.default),
        textbw,
    }
end

local function buildBannerMessage(textw, highlight_width, fgcolor)
    local textbw = styleTextWidget(textw)

    local width_mode = config.read(K.screensaver_message.width.mode)
    local custom_width = config.read(K.screensaver_message.width.custom_mode)

    local banner_width
    if width_mode == "viewport" then
        banner_width = Screen:getWidth()
    elseif width_mode == "message_content" then
        banner_width = textbw:getSize().w
    elseif width_mode == "custom" then
        if type(custom_width) ~= "number" or custom_width == math.huge or custom_width ~= custom_width then
            banner_width = Screen:getWidth()
        else
            banner_width = custom_width
        end
    else
        banner_width = highlight_width or Screen:getWidth() * 0.9
    end

    local padding = readNumber(K.screensaver_message.layout.padding, Size.padding.large)
    local margin = readNumber(K.screensaver_message.layout.margin, Size.margin.default)

    local banner_content = VerticalGroup:new {
        LineWidget:new {
            dimen = Geom:new { w = banner_width, h = Size.border.default },
            background = fgcolor,
        },
        VerticalSpan:new { width = padding },
        textbw,
        VerticalSpan:new { width = padding },
    }

    return FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        bordersize = 0,
        padding = 0,
        margin = margin,
        dimen = { w = banner_width },
        banner_content,
    }
end

----------------------------------------------------------------
-- Screensaver message builder
----------------------------------------------------------------
local function buildScreensaverMessageWidget(ui, base_font_size, content_width, fgcolor)
    if not config.read(K.koreader.screensaver.show_message) then
        return nil
    end

    local message = config.read(K.koreader.screensaver.message)
    if not message or message == "" then
        return nil
    end

    if ui and ui.bookinfo then
        message = ui.bookinfo:expandString(message) or message
    end

    local textw = TextBoxWidget:new {
        text = message,
        face = Font:getFace("infofont", config.read(K.screensaver_message.layout.font_size)),
        alignment = config.read(K.screensaver_message.layout.alignment) or "center",
        line_height = config.read(K.screensaver_message.layout.line_spacing),
    }

    local container_type = config.read(K.koreader.screensaver.container) or "box"

    if container_type == "banner" then
        return buildBannerMessage(textw, content_width, fgcolor)
    end

    return buildBoxMessage(textw)
end

----------------------------------------------------------------
-- Notes configuration (UNCHANGED)
----------------------------------------------------------------
local function getNoteConfig()
    if config.read(K.notes.sync_with_highlights) then
        return {
            text_alignment = config.read(K.highlights.alignment) or "left",
            line_height = (config.read(K.highlights.line_height) or 100) / 100,
            width_percent = config.read(K.highlights.width_percent) or 90,
            font_base = config.read(K.highlights.font_size_base) or 48,
            font_min = config.read(K.highlights.font_size_min) or 12,
        }
    else
        return {
            text_alignment = config.read(K.notes.alignment) or "left",
            line_height = (config.read(K.notes.line_height) or 100) / 100,
            width_percent = config.read(K.notes.width_percent) or 90,
            font_base = config.read(K.notes.font_base) or 48,
            font_min = config.read(K.notes.font_min) or 12,
        }
    end
end


----------------------------------------------------------------
-- Main entry
----------------------------------------------------------------
function M.buildHighlightsScreensaverWidget(ui, clipping)
    local col_fg, col_bg = getThemeColors()
    local fonts = config.getFonts()

    local hs_cfg = getNoteConfig()
    local hs_width = Screen:getWidth() * (hs_cfg.width_percent / 100)

    local function buildContent(base_font_size)
        local function fontSizeAlt()
            return math.ceil(base_font_size * 0.75)
        end

        local highlight_text = TextBoxWidget:new {
            text = clipping.text,
            face = Font:getFace(fonts.quote, base_font_size),
            width = hs_width,
            alignment = hs_cfg.text_alignment,
            justified = config.read(K.highlights.justified),
            line_height = hs_cfg.line_height,
            fgcolor = col_fg,
            bgcolor = col_bg,
        }

        local highlight_group = HorizontalGroup:new {
            LineWidget:new {
                dimen = Geom:new {
                    w = Size.border.thick,
                    h = highlight_text:getSize().h,
                },
                background = col_fg,
            },
            HorizontalSpan:new { width = config.read(K.highlights.border_spacing) or 24 },
            highlight_text,
        }

        local author_suffix = clipping.source_author and (", " .. clipping.source_author) or ""

        local source_text = TextBoxWidget:new {
            text = "— " .. clipping.source_title .. author_suffix,
            face = Font:getFace(fonts.author, fontSizeAlt()),
            width = hs_width,
            fgcolor = col_fg,
            bgcolor = col_bg,
            alignment = "left",
        }

        local content = VerticalGroup:new {
            highlight_group,
            VerticalSpan:new { width = 24 },
            source_text,
        }

        -- Notes
        local notes_option = config.read(K.notes.option.mode) or "full"

        if clipping.note and clipping.note ~= "" and notes_option ~= "disable" then
            local note_text_value = clipping.note
            if notes_option == "short" then
                local max_chars = config.read(K.notes.option.limit) or 70
                if #note_text_value > max_chars then
                    note_text_value = note_text_value:sub(1, max_chars) .. "..."
                end
            end

            local note_width = Screen:getWidth() * (hs_cfg.width_percent / 100)
            local note_font_size = math.ceil(hs_cfg.font_base * 0.75)

            local note_text = TextBoxWidget:new {
                text = note_text_value,
                face = Font:getFace(fonts.note, note_font_size),
                width = note_width,
                fgcolor = col_fg,
                bgcolor = col_bg,
                alignment = hs_cfg.text_alignment,
                line_height = hs_cfg.line_height,
            }

            table.insert(content, VerticalSpan:new { width = 32 })
            table.insert(content,
                    LineWidget:new {
                        dimen = Geom:new { w = note_width, h = Size.line.thin },
                        background = col_fg,
                    }
            )
            table.insert(content, VerticalSpan:new { width = 24 })
            table.insert(content, note_text)
        end

        return content
    end

    local font_size = hs_cfg.font_base
    local content = buildContent(font_size)
    while content:getSize().h > Screen:getHeight() * 0.95 and font_size > hs_cfg.font_min do
        font_size = font_size - 2
        content = buildContent(font_size)
    end

    local message_widget = buildScreensaverMessageWidget(ui, font_size, content:getSize().w, col_fg)

    local final_content
    if message_widget and config.read(K.koreader.screensaver.container) == "banner" then
        final_content = OverlapGroup:new {
            CenterContainer:new {
                dimen = Screen:getSize(),
                content,
            },
            BottomContainer:new {
                dimen = Screen:getSize(),
                message_widget,
            },
        }
    else
        final_content = VerticalGroup:new { content, message_widget }
    end

    return ScreenSaverWidget:new {
        widget = CenterContainer:new {
            dimen = Screen:getSize(),
            final_content,
            padding = 0,
            margin = 0,
            bgcolor = col_bg,
        },
        background = col_bg,
        covers_fullscreen = true,
    }
end

return M
