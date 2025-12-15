-- widgets/directory_picker.lua
local UIManager = require("ui/uimanager")
local PathChooser = require("ui/widget/pathchooser")
local InfoMessage = require("ui/widget/infomessage")
local Logger = require("logger")

local M = {}

-- helper to trim whitespace/newlines
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.pickDirectory(onConfirm)
    local chooser = PathChooser:new{
        select_file = false,   -- directory only
        path = "/",            -- starting path
        onConfirm = function(dir_path)
            local clean_path = trim(dir_path)
            Logger.info("[DirectoryPicker] Selected: " .. clean_path)

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
