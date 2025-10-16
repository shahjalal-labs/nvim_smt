-- w: ╭──────────── Block Start ────────────╮
--t: Function to send build command to tmux pane
function SendBuildCommandToTmuxPane()
	vim.ui.input({ prompt = "Enter tmux pane number (default 2): " }, function(input)
		-- If input is empty or nil, default to "2"
		local pane = (input == nil or input == "") and "2" or input

		local cmd = "bun run build && cp dist/index.html dist/200.html && surge ./dist"
		local tmux_cmd = string.format("tmux send-keys -t %s '%s' Enter", pane, cmd)

		vim.fn.system(tmux_cmd)
		print("Command sent to tmux pane " .. pane)
	end)
end

vim.api.nvim_set_keymap("n", "<leader>tb", ":lua SendBuildCommandToTmuxPane()<CR>", { noremap = true, silent = true })

-- w: ╰───────────── Block End ─────────────╯
-- w: ╭──────────── Block Start ────────────╮
-- Sends current line or visual selection to a Tmux pane.
-- Features:
--   - Normal mode: sends the current line
--   - Visual mode: sends the selected block
--   - Prompts for Tmux pane number (defaults to pane 2 if blank)
--   - Sends command to the specified Tmux pane using `tmux send-keys`

function SendCliCommandToTmuxPane()
	local mode = vim.fn.mode()
	local command = ""

	-- Get command based on mode
	if mode == "v" or mode == "V" then
		vim.cmd('normal! gv"xy') -- Copy visual selection to register "x"
		command = vim.fn.getreg("x")
	else
		command = vim.api.nvim_get_current_line()
	end

	command = command:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace

	if command == "" then
		vim.notify("No command to execute!", vim.log.levels.WARN)
		return
	end

	local pane_number = vim.fn.input("Enter Tmux Pane Number (default: 2): ")
	if pane_number == "" then
		pane_number = "2"
	end

	local tmux_command = string.format('tmux send-keys -t %s "%s" Enter', pane_number, command)
	vim.fn.system(tmux_command)

	vim.notify("Sent to Tmux Pane " .. pane_number .. ": " .. command, vim.log.levels.INFO)
end

-- Keybindings: Alt + d in Normal, Insert, and Visual modes
vim.api.nvim_set_keymap("n", "<A-d>", ":lua SendCliCommandToTmuxPane()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-d>", "<Esc>:lua SendCliCommandToTmuxPane()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<A-d>", ":lua SendCliCommandToTmuxPane()<CR>", { noremap = true, silent = true })
-- w: ╰───────────── Block End ─────────────╯
--
-- w: ╭──────────── Block Start ────────────╮
--bun install from clipboard  in tmux pane with timeout, auto-closes input, and logs to src/docs/cli_commands.md
local function run_clipboard_bun()
	local uv = vim.loop

	-- ──────── 1️⃣ Get clipboard content ─────────
	local function get_clipboard()
		local handle = io.popen("wl-paste 2>/dev/null") -- Wayland
		local result = handle and handle:read("*a")
		if handle then
			handle:close()
		end

		if result == nil or result == "" then
			-- fallback to xclip (X11)
			local xhandle = io.popen("xclip -selection clipboard -o 2>/dev/null")
			result = xhandle and xhandle:read("*a")
			if xhandle then
				xhandle:close()
			end
		end

		return result and result:gsub("%s+$", "") or ""
	end

	local cmd = get_clipboard()
	if cmd == "" then
		print("Clipboard empty, nothing to run.")
		return
	end

	-- ──────── 2️⃣ Transform command ─────────
	if cmd:match("^npm%s+install") then
		cmd = cmd:gsub("^npm%s+install", "bun add")
	elseif not cmd:match("^bun%s+add") then
		cmd = "bun add " .. cmd
	end

	-- ──────── 3️⃣ Timed tmux input ─────────
	local function timed_tmux_input(command, default_pane, timeout_ms)
		local used = false
		local timer = uv.new_timer()
		timer:start(timeout_ms, 0, function()
			if not used then
				used = true
				timer:stop()
				timer:close()
				vim.schedule(function()
					local send_cmd = string.format("tmux send-keys -t %s '%s' Enter", default_pane, command)
					os.execute(send_cmd)
					print("Sent to tmux pane " .. default_pane .. " (default): " .. command)
				end)
			end
		end)

		vim.schedule(function()
			vim.ui.input({ prompt = "Tmux pane (default " .. default_pane .. "): " }, function(input)
				if used then
					return
				end
				used = true
				timer:stop()
				timer:close()
				local pane = input and input ~= "" and input or default_pane
				local send_cmd = string.format("tmux send-keys -t %s '%s' Enter", pane, command)
				os.execute(send_cmd)
				print("Sent to tmux pane " .. pane .. ": " .. command)
			end)
		end)
	end

	timed_tmux_input(cmd, "2", 1500)

	-- ──────── 4️⃣ Log command ─────────
	local log_path = vim.fn.getcwd() .. "/src/docs/cli_commands.md"
	local log_dir = vim.fn.fnamemodify(log_path, ":h")
	if vim.fn.isdirectory(log_dir) == 0 then
		vim.fn.mkdir(log_dir, "p")
	end
	local file = io.open(log_path, "a")
	if file then
		file:write(cmd .. "\n")
		file:close()
	end
end

-- ──────── 5️⃣ Keymap ─────────
vim.keymap.set(
	"n",
	"<leader>ci",
	run_clipboard_bun,
	{ noremap = true, silent = true, desc = "bun install in tmux with prompt pane id and log to src/docs/cli.md file" }
)

-- w: ╰───────────── Block End ─────────────╯
