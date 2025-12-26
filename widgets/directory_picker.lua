-- widgets/directory_picker.lua
local UIManager = require("ui/uimanager")
local PathChooser = require("ui/widget/pathchooser")
local InfoMessage = require("ui/widget/infomessage")
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local Logger = require("logger")
local lfs = require("libs/libkoreader-lfs")
local ffiUtil = require("ffi/util")

local M = {}

-- Storage file for last path
local SETTINGS_FILE = DataStorage:getDataDir() .. "/directory_picker.lua"
local settings = LuaSettings:open(SETTINGS_FILE)

-- helper to trim whitespace/newlines
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Get safe fallback directory
local function getFallbackDir()
    if lfs.attributes("/mnt/us", "mode") == "directory" then
        return "/mnt/us"
    else
        return ffiUtil.realpath(DataStorage:getDataDir()) or "/"
    end
end

-- Get last path for a specific plugin, fallback to safe directory
local function getLastPath(plugin_name)
    local last_path = settings:readSetting(plugin_name .. "_last_path")
    if last_path and last_path ~= "" then
        -- ensure it still exists
        if lfs.attributes(last_path, "mode") == "directory" then
            return last_path
        end
    end
    return getFallbackDir()
end

-- Save last selected path for a specific plugin
local function saveLastPath(plugin_name, path)
    settings:saveSetting(plugin_name .. "_last_path", path)
    settings:flush()
end

-- Show PathChooser
-- plugin_name: string, used to remember last path per plugin
-- onConfirm: callback with the selected directory
function M.pickDirectory(plugin_name, onConfirm)
    local chooser = PathChooser:new{
        select_file = false, -- directory only
        path = getLastPath(plugin_name),
        onConfirm = function(dir_path)
            local clean_path = trim(dir_path)
            Logger.info("[DirectoryPicker] Selected: " .. clean_path)

            -- Save this path for next time
            saveLastPath(plugin_name, clean_path)

            UIManager:show(InfoMessage:new{
                text = "Selected directory:\n" .. clean_path,
                timeout = 4,
            })

            if onConfirm then
                onConfirm(clean_path)
            end
        end,
    }

    UIManager:show(chooser)
end

return M
