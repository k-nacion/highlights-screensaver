local M = {}

local LOG_PREFIX = "[HighlightSS Plugin]"

local function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function log(level, msg)
    local line = string.format(
        "%s %s [%s] %s",
        timestamp(),
        LOG_PREFIX,
        level,
        tostring(msg)
    )
    print(line)
end

function M.info(msg)
    log("INFO", msg)
end

function M.warn(msg)
    log("WARN", msg)
end

function M.error(msg)
    log("ERROR", msg)
end

return M
