local postwin = require("sapf.postwin")
local config = require("sapf.config")
local M = {}

M.proc = nil
M.job_id = nil

function M.is_running()
	return M.proc ~= nil
end

local function on_stdout(data)
	local text = table.concat(data, "\n")
	text = text:gsub("\r", "")
	postwin.post(text)
end

local function on_stderr(data)
	local text = table.concat(data, "\n")
	text = text:gsub("\r", "")
	postwin.post(text)
	postwin.open()
end

function M.start()
	if M.is_running() then
        vim.notify("[sapf.nvim] sapf is already running", vim.log.levels.WARN)
		return
	end

	local job_opts = {
		on_stdout = function(chan_id, data, name)
			on_stdout(data)
		end,
		on_stderr = function(chan_id, data, name)
			on_stderr(data)
		end,
		pty = true,
	}

	local proc = vim.fn.jobstart("sapf", job_opts)
	M.proc = proc
	postwin.open()
end

function M.send(command)
	if not M.is_running() then
		M.start()
	end
	vim.fn.chansend(M.proc, command .. "\n")
end

function M.stop()
	M.send("stop")
end

function M.clear()
	M.send("clear")
end

function M.terminate()
	if M.is_running() then
		M.send("quit")
		-- M.proc:kill("TERM")
		M.proc = nil
	end
end

function M.restart()
	if M.is_running() then
		M.terminate()
	end
	M.start()
end

return M
