local postwin = require("sapf.postwin")
local repl = require("sapf.repl")

local M = {}

local function make_user_commands()
	vim.api.nvim_buf_create_user_command(0, "SapfStart", repl.start, {})
	vim.api.nvim_buf_create_user_command(0, "SapfEval", M.eval, {})
	vim.api.nvim_buf_create_user_command(0, "SapfStop", repl.stop, {})
	vim.api.nvim_buf_create_user_command(0, "SapfPostWindowToggle", postwin.toggle, {})
	vim.api.nvim_buf_create_user_command(0, "SapfPostWindowOpen", postwin.open, {})
	vim.api.nvim_buf_create_user_command(0, "SapfPostWindowClose", postwin.close, {})
	vim.api.nvim_buf_create_user_command(0, "SapfPostWindowClear", postwin.clear, {})
	vim.api.nvim_buf_create_user_command(0, "SapfTerminate", repl.terminate, {})
	vim.api.nvim_buf_create_user_command(0, "SapfRestart", repl.restart, {})
end

local function create_autocmds()
	local id = vim.api.nvim_create_augroup("sapf_editor", {})
	vim.api.nvim_create_autocmd("FileType", {
		group = id,
		pattern = { "sapf", "sapf_repl" },
		callback = function()
			make_user_commands()
			vim.bo.commentstring = "; %s"
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = id,
		pattern = { "sapf", "sapf_repl" },
		callback = function()
			repl.terminate()
		end,
	})
end

M.setup = function()
	create_autocmds()
end

local function get_paragraph()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! vip"sy')
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	local paragraph = vim.trim(vim.fn.getreg("s"))
	return paragraph
end

function M.eval()
	local text = get_paragraph()
	repl.send(text)
end

return M
