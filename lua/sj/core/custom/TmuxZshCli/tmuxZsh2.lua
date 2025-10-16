-- ╭──────────── Block Start ────────────╮

-- ╰───────────── Block End ─────────────╯

local keymap = vim.keymap

--p: ╭──────────── Block Start ────────────╮
--t: Function to restore specific tmux layouts
function restore_tmux_layouts()
	vim.fn.system("tmux select-layout -t 0 '8d8d,210x44,0,0[210x27,0,0,4,210x16,0,28{104x16,0,28,5,105x16,105,28,6}]'")
	vim.fn.system("tmux select-layout -t 2 '6520,210x44,0,0[210x28,0,0,7,210x15,0,29{104x15,0,29,8,105x15,105,29,9}]'")
	vim.fn.system(
		"tmux select-layout -t 3 '2ecf,210x44,0,0[210x32,0,0,10,210x11,0,33{107x11,0,33,11,102x11,108,33,12}]'"
	)
end

keymap.set("n", "<leader>aa", ":lua restore_tmux_layouts()<CR>", { noremap = true, silent = true })
--p: ╰───────────── Block End ─────────────╯

--
--

--p: ╭──────────── Block Start ────────────╮
--t: clear tmux panes
vim.api.nvim_set_keymap("n", "<space>al", ":lua ClearOtherTmuxPanes()<CR>", { noremap = true, silent = true })
function ClearOtherTmuxPanes()
	-- Get the tmux pane ID for the current Neovim instance
	local current_pane = vim.fn.system('tmux display-message -p "#{pane_id}"'):gsub("%s+", "")

	-- Get a list of all tmux panes
	local panes = vim.fn.systemlist('tmux list-panes -F "#{pane_id}"')

	for _, pane in ipairs(panes) do
		if pane ~= current_pane then
			vim.fn.system("tmux send-keys -t " .. pane .. ' "clear" C-m')
		end
	end

	-- Notify the user
	vim.notify("Cleared all tmux panes except the active Neovim pane")
	vim.api.nvim_set_keymap("n", "<space>al", ":lua ClearOtherTmuxPanes()<CR>", { noremap = true, silent = true })

	function ClearOtherTmuxPanes()
		-- Get the tmux pane ID for the current Neovim instance
		local current_pane = vim.fn.system('tmux display-message -p "#{pane_id}"'):gsub("%s+", "")

		-- Get a list of all tmux panes
		local panes = vim.fn.systemlist('tmux list-panes -F "#{pane_id}"')

		-- Loop through each pane and clear it if it is not the current Neovim pane
		for _, pane in ipairs(panes) do
			if pane ~= current_pane then
				vim.fn.system("tmux send-keys -t " .. pane .. ' "clear" C-m')
			end
		end

		-- Clear Neovim's integrated terminal if in terminal mode
		if vim.bo.buftype == "terminal" then
			vim.api.nvim_feedkeys("i<C-u>", "n", true) -- Clear the terminal buffer
		end

		-- Notify the user
		vim.notify("Cleared all tmux panes except the active Neovim pane")
	end
end
--p: ╰───────────── Block End ─────────────╯
--

-- update another time

--
--
--
--
--
--

--p: ╭──────────── Block Start ────────────╮
--w: yank the current projects root path
vim.keymap.set("n", "<leader>cr", function()
	vim.fn.setreg("+", vim.fn.getcwd())
	print("Copied root directory: " .. vim.fn.getcwd())
end, { desc = "Copy root directory to clipboard" })
--p: ╰───────────── Block End ─────────────╯

--p: ╭──────────── Block Start ────────────╮
local function run_clipboard_command()
	-- Get clipboard content
	local command = vim.fn.getreg("+"):gsub("\n", "") -- Remove newlines

	if command == "" then
		vim.notify("Clipboard is empty!", vim.log.levels.WARN)
		return
	end

	-- Notify user that command is running
	vim.notify("Running: " .. command, vim.log.levels.INFO)

	-- Start job to run command and capture output
	vim.fn.jobstart(command, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
			end
		end,
	})
end

-- Use `vim.keymap.set` which works better with Lua functions
vim.keymap.set("n", "<leader>rr", run_clipboard_command, { noremap = true, silent = true })
--p: ╰───────────── Block End ─────────────╯
