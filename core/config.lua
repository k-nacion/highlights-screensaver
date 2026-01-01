local json = require("json")
local utils = require("core.utils")
local K = require("core.keys")

local M = {}

M.defaults = {
    [K.screensaver_message.layout.font_size] = 12,
    [K.screensaver_message.layout.line_spacing] = 1.2,
    [K.screensaver_message.layout.alignment] = "center",

    [K.screensaver_message.layout.padding] = 16,
    [K.screensaver_message.layout.margin] = 24,
}

function M.read(key)
    return G_reader_settings:readSetting(key, M.defaults[key])
end

function M.write(key, value)
    G_reader_settings:saveSetting(key, value)
end

function M.migrate()
    local rs = G_reader_settings

    local legacy = {
        screensaver_message_line_spacing = K.screensaver_message.layout.line_spacing,
        screensaver_message_font_size = K.screensaver_message.layout.font_size,
    }

    for old, new in pairs(legacy) do
        if rs:has(old) and not rs:has(new) then
            rs:saveSetting(new, rs:readSetting(old))
        end
    end
end

M.Theme = {
    SYSTEM = "system", -- new system theme
    DARK = "dark",
    LIGHT = "light",
}

---@class Fonts
---@field quote string
---@field author string
---@field note string
local Fonts = {}
Fonts.__index = Fonts

---@class Config
---@field theme Theme
---@field scannable_directories string[]
---@field last_scanned_date string|nil
---@field last_shown_highlight string|nil
---@field fonts Fonts
local Config = {}
Config.__index = Config

local function getConfigFilePath()
    return utils.getPluginDir() .. "/config.json"
end

local function load()
    local default_fonts = setmetatable({
        quote = "NotoSerif-BoldItalic.ttf",
        author = "NotoSerif-Regular.ttf",
        note = "NotoSerif-Bold.ttf",
    }, Fonts)

    local default_config = setmetatable({
        theme = M.Theme.SYSTEM, -- default theme is system
        scannable_directories = {},
        last_scanned_date = nil,
        last_shown_highlight = nil,
        fonts = default_fonts,
        external_quotes_directory = nil,
    }, Config)

    local file = io.open(getConfigFilePath(), "r")
    if not file then
        return default_config
    end

    local content = file:read("*a")
    file:close()
    local data = json.decode(content)
    if not data then
        return default_config
    end

    return setmetatable({
        theme = data.theme or M.Theme.SYSTEM, -- default to system
        scannable_directories = data.scannable_directories or {},
        last_scanned_date = data.last_scanned_date or nil,
        last_shown_highlight = data.last_shown_highlight or nil,
        fonts = data.fonts or default_fonts,
        external_quotes_directory = data.external_quotes_directory or nil,
    }, Config)
end

local function deep_copy_no_mt(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deep_copy_no_mt(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Config:save()
    local copy = deep_copy_no_mt(self)
    local content = json.encode(copy, { indent = true })
    utils.makeDir(utils.getPluginDir())
    local file = assert(io.open(getConfigFilePath(), "w"))
    file:write(content)
    file:close()
end

---@return Theme
function M.getTheme()
    local config = load()
    return config.theme
end

---@param theme Theme
function M.setTheme(theme)
    local config = load()
    config.theme = theme
    config:save()
end

---@return string[]
function M.getScannableDirectories()
    local config = load()
    return config.scannable_directories
end

---@param dirs string[]
function M.setScannableDirectories(dirs)
    local config = load()
    config.scannable_directories = dirs
    config:save()
end

---@return string|nil
function M.getLastScannedDate()
    local config = load()
    return config.last_scanned_date
end

---@param date string
function M.setLastScannedDate(date)
    local config = load()
    config.last_scanned_date = date
    config:save()
end

---@return string|nil
function M.getLastShownHighlight()
    local config = load()
    return config.last_shown_highlight
end

---@param filename string
function M.setLastShownHighlight(filename)
    local config = load()
    config.last_shown_highlight = filename
    config:save()
end

---@return string|nil
function M.getExternalQuotesDirectory()
    local config = load()
    return config.external_quotes_directory
end

---@param dir string
function M.setExternalQuotesDirectory(dir)
    local config = load()
    config.external_quotes_directory = dir
    config:save()
end

---@param fonts Fonts
function M.setFonts(fonts)
    local config = load()
    config.fonts = fonts
    config:save()
end

---@return Fonts
function M.getFonts()
    local config = load()
    return config.fonts
end

M.Fonts = Fonts

return M
