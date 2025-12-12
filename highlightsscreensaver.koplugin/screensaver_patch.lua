local Screensaver = require("ui/screensaver")
local highlightsWidget = require("highlights_widget")
local config = require("config")
local clipper = require("clipper")
local scan = require("scan")
local UIManager = require("ui/uimanager")
local Device = require("device")
local Screen = Device.screen

local HIGHLIGHTS_MODE = "highlights"
local ORIENT_DEFAULT = "default"
local ORIENT_PORTRAIT = "portrait"
local ORIENT_LANDSCAPE = "landscape"
local ROT_UPRIGHT = Screen.DEVICE_ROTATED_UPRIGHT or 0
local ROT_LEFT    = Screen.DEVICE_ROTATED_LEFT or 1

local function patchScreensaverShow()
    local og_screensaver_show = Screensaver.show
    Screensaver.show = function(self)
        if self.screensaver_type == HIGHLIGHTS_MODE then
            if self.screensaver_widget then
                UIManager:close(self.screensaver_widget)
                self.screensaver_widget = nil
            end

            Device.screen_saver_mode = true

            local mode = G_reader_settings:readSetting("highlights_orientation") or ORIENT_DEFAULT
            if mode == ORIENT_PORTRAIT then
                Screen:setRotationMode(ROT_UPRIGHT)
            elseif mode == ORIENT_LANDSCAPE then
                Screen:setRotationMode(ROT_LEFT)
            end

            local last_scanned = config.getLastScannedDate()
            local t = os.date("*t")
            local today = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
            if not last_scanned or last_scanned < today then
                scan.scanHighlights()
            end

            local clipping = clipper.getRandomClipping()
            config.setLastShownHighlight(clipping:filename())

            self.screensaver_widget = highlightsWidget.buildHighlightsScreensaverWidget(clipping)
            self.screensaver_widget.modal = true
            self.screensaver_widget.dithered = true
            UIManager:show(self.screensaver_widget, "full")
            return
        end

        og_screensaver_show(self)
    end
end

return {
    patchScreensaverShow = patchScreensaverShow,
}
