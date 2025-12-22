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
local logger = require("logger")


local M = {}

function M.buildHighlightsScreensaverWidget(clipping)
	local theme = config.getTheme()
	local fonts = config.getFonts()
	local theme_setting = config.getTheme()

	local col_fg, col_bg
	local is_night_mode = G_reader_settings:isTrue("night_mode")

	logger.info("Theme setting = " .. tostring(theme))
	logger.info("night_mode = " .. tostring(is_night_mode))

	if theme == config.Theme.SYSTEM then
			logger.info("Branch = SYSTEM")

			
			if is_night_mode then
				-- Draw LIGHT so it inverts to DARK
				col_fg = Blitbuffer.COLOR_BLACK
				col_bg = Blitbuffer.COLOR_WHITE
				logger.info("SYSTEM result = DARK (inverted by night mode)")
			else
				-- Draw LIGHT normally
				col_fg = Blitbuffer.COLOR_BLACK
				col_bg = Blitbuffer.COLOR_WHITE
				logger.info("SYSTEM result = LIGHT")
			end

	elseif (theme == config.Theme.DARK and not is_night_mode)
		or (theme == config.Theme.LIGHT and is_night_mode) then

		logger.info("Branch = INVERT → DARK")
		col_fg = Blitbuffer.COLOR_WHITE
		col_bg = Blitbuffer.COLOR_BLACK

	else
		logger.info("Branch = INVERT → LIGHT")
		col_fg = Blitbuffer.COLOR_BLACK
		col_bg = Blitbuffer.COLOR_WHITE
	end




	local text_alignment = G_reader_settings:readSetting("hs_text_alignment") or "left"
	local justified = G_reader_settings:isTrue("hs_justified")
	local lh_raw = G_reader_settings:readSetting("hs_line_height") or 0
	-- allow full range from 0 to 160
	lh_raw = math.min(math.max(lh_raw, 0), 160)
	line_height = lh_raw / 100


	local width_percent = G_reader_settings:readSetting("hs_width_percent") or 90
	local width = Screen:getWidth() * (width_percent / 100)


	local function buildContent(base_font_size)
		local function fontSizeAlt()
			return math.ceil(base_font_size * 0.75)
		end

		local highlight_text = TextBoxWidget:new({
			text = clipping.text,
			face = Font:getFace(fonts.quote, base_font_size),
			width = width,
			alignment = text_alignment,
			justified = justified,
			line_height = line_height,
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
				local max_chars = G_reader_settings:readSetting("show_notes_limit") or 70  -- get its value from global settings instead rather than hardcoding it. 
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
				alignment = 0,
				line_height = line_height,
			})

			-- Insert into content
			table.insert(content, VerticalSpan:new({ width = 32 }))
			table.insert(content, separator)
			table.insert(content, VerticalSpan:new({ width = 24 }))
			table.insert(content, note_text)
		end


		return content
	end

	local font_size_base = G_reader_settings:readSetting("hs_font_size_base") or 48
	local font_size_min  = G_reader_settings:readSetting("hs_font_size_min") or 12
	local content = buildContent(font_size_base)

	-- Shrink font if it overflows, but never go below min font size
	while content:getSize().h > Screen:getHeight() * 0.95 and font_size_base > font_size_min do
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
