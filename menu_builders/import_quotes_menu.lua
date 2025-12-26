
local config = require("../config")
local DirectoryPicker = require("widgets/directory_picker")
local _ = require("gettext")

local function buildMenuImportExternalQuotes()
    return {
        text_func = function()
            local dir = config.getExternalQuotesDirectory()
            if not dir then
                return _("Import external quotes")
            end
            local folder_name = dir:match("([^/]+)$") or dir
            return _("External Quotes Location") .. ": " .. folder_name
        end,
        callback = function()
             DirectoryPicker.pickDirectory("highlightsscreensaver", function(dir_path)
				config.setExternalQuotesDirectory(dir_path) -- save last folder
				local externalQuotes = require("external_quotes")
				externalQuotes.importQuotes(dir_path)
			end)
        end,
        separator = true,
    }
end

return { buildMenuImportExternalQuotes = buildMenuImportExternalQuotes }
