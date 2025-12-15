-- external_quotes.lua
local lfs = require("libs/libkoreader-lfs")
local Logger = require("logger")
local clipper = require("clipper")
local utils = require("utils")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")

local M = {}

-- helper to trim whitespace/newlines
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

---@param dir_path string
function M.importQuotes(dir_path)
    Logger.info("[ExternalQuotes] Importing quotes from: " .. dir_path)
    local imported_count = 0

    for file in lfs.dir(dir_path) do
        local clean_file = trim(file)  -- trim whitespace/newlines
        Logger.info("[ExternalQuotes] scanning file: '" .. file .. "'")

        if clean_file:match("%.txt$") then
            Logger.info("[ExternalQuotes] Matched txt file: " .. clean_file)

            local filepath = dir_path .. "/" .. clean_file
            local f = io.open(filepath, "r")
            if f then
                local content = f:read("*a")
                f:close()

                -- skip empty files
                if content and content:match("%S") then
                    local clipping = clipper.Clipping.new(
                        content,
                        nil,  -- no note
                        os.date("%Y-%m-%d %H:%M:%S"),
                        clean_file:gsub("%.txt$", ""), -- use filename as source title
                        nil,
                        true
                    )
                    clipper.saveClipping(clipping)
                    imported_count = imported_count + 1
                    Logger.info("[ExternalQuotes] Imported: " .. clean_file)
                    Logger.info("[ExternalQuotes] File content:\n" .. content)  -- remove this temporary console log.

                else
                    Logger.info("[ExternalQuotes] Empty file skipped: " .. clean_file)
                end
            else
                Logger.info("[ExternalQuotes] Failed to open: " .. filepath)
            end
        end
    end

    local msg = string.format(
        "Imported %d quote(s) from directory:\n%s",
        imported_count,
        dir_path
    )
    UIManager:show(InfoMessage:new({ text = msg }))
end

return M
