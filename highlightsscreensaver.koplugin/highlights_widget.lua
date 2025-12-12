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

local M = {}

function M.buildHighlightsScreensaverWidget(clipping)
	local theme = config.getTheme()
	local fonts = config.getFonts()
	local col_fg, col_bg

  -- night mode inverts colours, leading to unintuitive behaviour. instead, i check night mode status
  -- and manually reverse the colours so that they appear dark/light as specified by the user.
  local is_night_mode = G_reader_settings:isTrue("night_mode")
  if (theme == config.Theme.DARK and not is_night_mode) or (theme == config.Theme.LIGHT and is_night_mode) then
    -- set dark mode settings (will be flipped back to light if is_night_mode)
		col_fg = Blitbuffer.COLOR_WHITE
		col_bg = Blitbuffer.COLOR_BLACK
  else -- (dark mode and is_night_mode) or (light mode and not is_night_mode)
    -- set light mode settings (will be flipped bakc to dark if is_night_mode)
		col_fg = Blitbuffer.COLOR_BLACK
		col_bg = Blitbuffer.COLOR_WHITE
  end

	local width = Screen:getWidth() * 0.90

	local function buildContent(base_font_size)
		local function fontSizeAlt()
			return math.ceil(base_font_size * 0.75)
		end

		local highlight_text = TextBoxWidget:new({
			text = clipping.text,
			face = Font:getFace(fonts.quote, base_font_size),
			width = width,
			alignment = "left",
			justified = false,
			line_height = 0.5,
			fgcolor = col_fg,
			bgcolor = col_bg,
		})
		local left_border = LineWidget:new({
			dimen = Geom:new({
				w = Size.border.thick,
				h = highlight_text:getSize().h,
			}),
			background = col_fg,
		})
		local highlight_group = HorizontalGroup:new({
			left_border,
			HorizontalSpan:new({ width = 30 }),
			highlight_text,
		})

		local author_suffix = ""
		if clipping.source_author and clipping.source_author ~= "" then
			author_suffix = ", " .. clipping.source_author
		end

		local source_text = TextBoxWidget:new({
			text = "— " .. clipping.source_title .. author_suffix,
			face = Font:getFace(fonts.author, fontSizeAlt()),
			width = width,
			fgcolor = col_fg,
			bgcolor = col_bg,
			alignment = "left",
		})

		local content = VerticalGroup:new({
			highlight_group,
			VerticalSpan:new({ width = 24 }),
			source_text,
		})

				-- NOTES HANDLING BASED ON SETTING
		local notes_option = G_reader_settings:readSetting("show_notes_option") or "full"

		if clipping.note and clipping.note ~= "" and notes_option ~= "disable" then
			-- Insert separator (only if notes are shown)
			local separator = LineWidget:new({
				dimen = Geom:new({
					w = width,
					h = Size.line.thin,
				}),
				background = col_fg,
			})

			local note_text_value = clipping.note

			-- Truncate to 2 lines
			if notes_option == "short" then
				-- Roughly estimate characters per line
				-- Simple + safe
				local max_chars = 100  -- adjust if needed
				if #note_text_value > max_chars then
					note_text_value = note_text_value:sub(1, max_chars) .. "..."
				end
			end

			local note_text = TextBoxWidget:new({
				text = note_text_value,
				face = Font:getFace(fonts.note, fontSizeAlt()),
				width = width,
				fgcolor = col_fg,
				bgcolor = col_bg,
				alignment = "left",
				line_height = 0.4,
			})

			-- Insert into content
			table.insert(content, VerticalSpan:new({ width = 32 }))
			table.insert(content, separator)
			table.insert(content, VerticalSpan:new({ width = 24 }))
			table.insert(content, note_text)
		end


		return content
	end

	local font_size_base = 48
	local content = buildContent(font_size_base)
	while content:getSize().h > Screen:getHeight() * 0.95 and font_size_base > 12 do
		font_size_base = font_size_base - 2
		content = buildContent(font_size_base)
	end

	local container = CenterContainer:new({
		dimen = Screen:getSize(),
		content,
		padding = 0,
		margin = 0,
		bgcolor = col_bg,
	})
	local screensaver_widget = ScreenSaverWidget:new({
		widget = container,
		background = col_bg,
		covers_fullscreen = true,
	})
	return screensaver_widget
end

return M
