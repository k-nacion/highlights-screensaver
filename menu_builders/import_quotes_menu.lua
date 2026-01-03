local _ = require("gettext")

local config = require("core.config")
local DirectoryPicker = require("widgets.directory_picker")

local function buildMenuImportExternalQuotes()
    return {
        text_func = function()
            local dir = config.getExternalQuotesDirectory()
            if not dir then
                return _("Import External Quotes")
            end
            local folder_name = dir:match("([^/]+)$") or dir
            return _("Reimport Quotes") .. ": " .. folder_name
        end,
        callback = function()
             DirectoryPicker.pickDirectory(function(dir_path)
				config.setExternalQuotesDirectory(dir_path) -- save last folder
				local externalQuotes = require("core.external_quotes")
				externalQuotes.importQuotes(dir_path)
			end)
        end,
        separator = true,
    }
end

return { buildMenuImportExternalQuotes = buildMenuImportExternalQuotes }
