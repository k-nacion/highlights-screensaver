local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local config = require("config")
local clipper = require("clipper")
local _ = require("gettext")

local function buildMenuDisableHighlight()
    return {
        text = _("Disable last shown highlight"),
        callback = function()
            local fname = config.getLastShownHighlight()
            if not fname then return end

            local clipping = clipper.getClipping(fname)
            if not clipping then return end

            clipping.enabled = false
            clipper.saveClipping(clipping)

            UIManager:show(InfoMessage:new({
                text = _("Disabled highlight: " .. clipping:filename()),
            }))
        end,
        separator = true
    }
end

return {
    buildMenuDisableHighlight = buildMenuDisableHighlight
}
