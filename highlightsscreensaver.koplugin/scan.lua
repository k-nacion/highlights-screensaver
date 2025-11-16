local utils = require("utils")
local clipper = require("clipper")

local M = {}

function M.scanHighlights()
	local sidecars = utils.getAllSidecarPaths()
	for _, sidecar in ipairs(sidecars) do
		local clippings = clipper.extractClippingsFromSidecar(sidecar)
		for _, clipping in ipairs(clippings) do
			clipper.saveClipping(clipping)
		end
	end
end

return M
