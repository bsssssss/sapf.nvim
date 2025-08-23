local config = require("sapf.config")
local editor = require("sapf.editor")

local M = {}

M.setup = function(opts)
	opts = opts or {}
	config.merge_with(opts)
	editor.setup()
end

return M
