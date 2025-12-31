local Blitbuffer = require("ffi/blitbuffer")
local CenterContainer = require("ui/widget/container/centercontainer")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local TextBoxWidget = require("ui/widget/textboxwidget")
local Device = require("device")
local config = require("config")
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



local M = {}

----------------------------------------------------------------
-- Theme helpers
----------------------------------------------------------------
local function getThemeColors()
    local theme = config.getTheme()
    local is_night_mode = G_reader_settings:isTrue("night_mode")

    if theme == config.Theme.SYSTEM then
        return Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    elseif (theme == config.Theme.DARK and not is_night_mode)
        or (theme == config.Theme.LIGHT and is_night_mode) then
        return Blitbuffer.COLOR_WHITE, Blitbuffer.COLOR_BLACK
    else
        return Blitbuffer.COLOR_BLACK, Blitbuffer.COLOR_WHITE
    end
end

----------------------------------------------------------------
-- Notes configuration
----------------------------------------------------------------
local function getNoteConfig()
    if G_reader_settings:isTrue("ns_sync_with_highlights") then
        return {
            text_alignment = G_reader_settings:readSetting("hs_text_alignment") or "left",
            line_height    = (G_reader_settings:readSetting("hs_line_height") or 100) / 100,
            width_percent  = G_reader_settings:readSetting("hs_width_percent") or 90,
            font_base      = G_reader_settings:readSetting("hs_font_size_base") or 48,
            font_min       = G_reader_settings:readSetting("hs_font_size_min") or 12,
        }
    else
        return {
            text_alignment = G_reader_settings:readSetting("ns_text_alignment") or "left",
            line_height    = (G_reader_settings:readSetting("ns_line_height") or 100) / 100,
            width_percent  = G_reader_settings:readSetting("ns_width_percent") or 90,
            font_base      = G_reader_settings:readSetting("ns_font_size_base") or 48,
            font_min       = G_reader_settings:readSetting("ns_font_size_min") or 12,
        }
    end
end

----------------------------------------------------------------
-- Screensaver message helpers
----------------------------------------------------------------

local function buildBoxMessage(textw, content_width)
    local frame_opts = {
        background = Blitbuffer.COLOR_WHITE,
        bordersize = Size.border.default,
        padding = Size.padding.large or 18,
        margin = Size.margin.default,
        textw,
    }

    if content_width then
        frame_opts.dimen = { w = content_width }
    end

    return FrameContainer:new(frame_opts)
end

local function buildBannerMessage(textw, content_width, fgcolor)
    local padding = Size.padding.large or 18

    local banner_content = VerticalGroup:new {
        -- Top border only
        LineWidget:new {
            dimen = Geom:new {
                w = content_width,
                h = Size.border.default,
            },
            background = fgcolor,
        },
        VerticalSpan:new { width = padding },
        textw,
        VerticalSpan:new { width = padding },
    }

    return FrameContainer:new {
        background = Blitbuffer.COLOR_WHITE,
        padding = 0,
        margin = Size.margin.default,
        dimen = content_width and { w = content_width } or nil,
        banner_content,
        bordersize = 0, -- remove all frame borders

    }
end

local function buildScreensaverMessageWidget(ui, base_font_size, match_content_width, content_width, fgcolor)
    if not G_reader_settings:isTrue("screensaver_show_message") then
        return nil
    end

    local message = G_reader_settings:readSetting("screensaver_message")
    if not message or message == "" then
        return nil
    end

    if ui and ui.bookinfo then
        message = ui.bookinfo:expandString(message) or message
    end

    local container_type =
        G_reader_settings:readSetting("screensaver_message_container") or "box"

    local font_size = math.max(math.floor(base_font_size * 0.25), 10)

    local textw = TextBoxWidget:new {
        text = message,
        face = Font:getFace("infofont", font_size),
        alignment = "left",
        line_height = 0,
    }

    local width = match_content_width and content_width or nil

    if container_type == "banner" then
        return buildBannerMessage(textw, width, fgcolor)
    end

    -- default / "box"
    return buildBoxMessage(textw, width)
end



----------------------------------------------------------------
-- Main builder
----------------------------------------------------------------
function M.buildHighlightsScreensaverWidget(ui, clipping)
    local col_fg, col_bg    = getThemeColors()
    local fonts             = config.getFonts()

    -- Highlight settings
    local hs_alignment      = G_reader_settings:readSetting("hs_text_alignment") or "left"
    local hs_justified      = G_reader_settings:isTrue("hs_justified")
    local hs_line_height    = math.min(
        math.max(G_reader_settings:readSetting("hs_line_height") or 0, 0),
        160
    ) / 100
    local hs_width          = Screen:getWidth() *
        ((G_reader_settings:readSetting("hs_width_percent") or 90) / 100)
    local hs_font_base      = G_reader_settings:readSetting("hs_font_size_base") or 48
    local hs_font_min       = G_reader_settings:readSetting("hs_font_size_min") or 12
    local hs_border_spacing = G_reader_settings:readSetting("hs_border_spacing") or 24

    ------------------------------------------------------------
    -- Content builder (resizes to fit screen)
    ------------------------------------------------------------
    local function buildContent(base_font_size)
        local function fontSizeAlt()
            return math.ceil(base_font_size * 0.75)
        end

        -- Highlight text
        local highlight_text = TextBoxWidget:new {
            text = clipping.text,
            face = Font:getFace(fonts.quote, base_font_size),
            width = hs_width,
            alignment = hs_alignment,
            justified = hs_justified,
            line_height = hs_line_height,
            fgcolor = col_fg,
            bgcolor = col_bg,
        }

        local highlight_group = HorizontalGroup:new {
            LineWidget:new {
                dimen = Geom:new {
                    w = Size.border.thick,
                    h = highlight_text:getSize().h
                },
                background = col_fg,
            },
            HorizontalSpan:new { width = hs_border_spacing },
            highlight_text,
        }

        local author_suffix =
            clipping.source_author and (", " .. clipping.source_author) or ""

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
        local notes_option = G_reader_settings:readSetting("show_notes_option") or "full"
        if clipping.note and clipping.note ~= "" and notes_option ~= "disable" then
            local note_cfg = getNoteConfig()
            local note_text_value = clipping.note

            if notes_option == "short" then
                local max_chars =
                    G_reader_settings:readSetting("show_notes_limit") or 70
                if #note_text_value > max_chars then
                    note_text_value = note_text_value:sub(1, max_chars) .. "..."
                end
            end

            local note_width = Screen:getWidth() *
                (note_cfg.width_percent / 100)
            local note_font_size = math.ceil(note_cfg.font_base * 0.75)

            local note_text = TextBoxWidget:new {
                text = note_text_value,
                face = Font:getFace(fonts.note, note_font_size),
                width = note_width,
                fgcolor = col_fg,
                bgcolor = col_bg,
                alignment = note_cfg.text_alignment,
                line_height = note_cfg.line_height,
            }

            table.insert(content, VerticalSpan:new { width = 32 })
            table.insert(content,
                LineWidget:new {
                    dimen = Geom:new {
                        w = note_width,
                        h = Size.line.thin
                    },
                    background = col_fg,
                }
            )
            table.insert(content, VerticalSpan:new { width = 24 })
            table.insert(content, note_text)
        end

        return content
    end

    ------------------------------------------------------------
    -- Auto-resize loop
    ------------------------------------------------------------
    local font_size_base = hs_font_base
    local content = buildContent(font_size_base)

    while content:getSize().h > Screen:getHeight() * 0.95
        and font_size_base > hs_font_min do
        font_size_base = font_size_base - 2
        content = buildContent(font_size_base)
    end

    ------------------------------------------------------------
    -- Screensaver message
    ------------------------------------------------------------
    local content_width = content:getSize().w
    local container_type = G_reader_settings:readSetting("screensaver_message_container") or "box"
    local message_widget = buildScreensaverMessageWidget(
        ui,
        font_size_base,
        true,
        content_width,
        col_fg
    )

    ------------------------------------------------------------
    -- Final composition
    ------------------------------------------------------------
    local final_content
    if message_widget and container_type == "banner" then
        -- Banner pinned to bottom
        local message_container = BottomContainer:new {
            dimen = Screen:getSize(), -- full viewport
            message_widget,
        }
        -- Wrap content in CenterContainer to preserve centering
        local content_container = CenterContainer:new {
            dimen = Screen:getSize(),
            content,
            padding = 24,                           -- adjust as needed
            margin = 0,
            bgcolor = Blitbuffer.COLOR_TRANSPARENT, -- keep background behind
        }


        final_content = OverlapGroup:new {
            content_container,
            message_container,
        }
    else
        -- Box or no message
        final_content = VerticalGroup:new {
            content,
            message_widget or nil,
        }
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
