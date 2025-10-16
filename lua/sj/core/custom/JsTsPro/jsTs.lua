--t: Function to insert a return statement based on the current file type
-- Set up the keybinding for m-r
vim.api.nvim_set_keymap("n", "<M-r>", "oreturn ", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<M-r>", "return ", { noremap = true, silent = true })
--
--
--
--
--
--
--w:  insert const variable with alt-m
vim.api.nvim_set_keymap("n", "<M-m>", "oconst = ;<Left><Left><Left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<M-m>", "<C-o>o const = ;<Left><Left><Left>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "<M-m>", "<C-o>o const variableName= ;<Esc>bb viwc", { noremap = true, silent = true })
--
--
--
--
--
--
--
--
--t: tempate string
vim.keymap.set("n", "<leader>jt", "i`${}`<Esc>i", { desc = "Insert template string" })
vim.keymap.set("i", "<leader>jt", "`${}`<Esc>hi", { desc = "Insert template string" })
--
--
--
--
--
--w:05/11/2024  09:55 AM Tue GMT+6  Sharifpur, Gazipur, Dhaka
--p: moveToEndOfPrevVariableName
function moveToEndOfPrevVariableName()
	local current_pos = vim.api.nvim_win_get_cursor(0)
	local line_num = current_pos[1]
	local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1] -- Get the current line content

	-- Check if the current line contains a variable declaration
	local current_var_declaration = line:find("const%s+") or line:find("let%s+") or line:find("var%s+")

	-- If the current line contains a declaration, skip to the previous line
	if current_var_declaration then
		line_num = line_num - 1
	end

	-- Search backwards for the previous variable declaration
	for i = line_num, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] -- Get the line content

		-- Check if the line contains a variable declaration
		local var_start = line:find("const%s+") or line:find("let%s+") or line:find("var%s+")
		if var_start then
			-- Find the equal sign '=' in the line after the variable declaration
			local equal_pos = line:find("=")
			if equal_pos then
				-- Move the cursor to the position of the equal sign
				vim.api.nvim_win_set_cursor(0, { i, equal_pos }) -- Move to the '=' sign

				-- Move cursor to the end of the variable name
				local var_end = line:sub(var_start, equal_pos - 1):match("%s*(%w+)%s*$")
				if var_end then
					local end_pos = var_start + #var_end - 1 -- Position at the end of the variable name
					vim.api.nvim_win_set_cursor(0, { i, end_pos })
				end
				return
			end
		end
	end
end

-- Key mapping
vim.api.nvim_set_keymap(
	"n",
	"<leader>jp",
	"<cmd>lua moveToEndOfPrevVariableName()<CR>",
	{ noremap = true, silent = true }
)
--
--
--
--
--
--w: 05/11/2024  10:17 AM Tue GMT+6  Sharifpur, Gazipur, Dhaka
--
--p: moveToEndOfNextVariableName
function moveToEndOfNextVariableName()
	local current_pos = vim.api.nvim_win_get_cursor(0)
	local line_num = current_pos[1]
	local total_lines = vim.api.nvim_buf_line_count(0)
	local current_line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

	-- Check if the current line has a variable declaration
	local current_var_decl = current_line:find("const%s+") or current_line:find("let%s+") or current_line:find("var%s+")

	-- Start searching from the next line if the current line has a variable declaration
	if current_var_decl then
		line_num = line_num + 1
	end

	-- Search forward for the next variable declaration
	for i = line_num, total_lines do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] -- Get the line content

		-- Check if the line contains a variable declaration
		local var_start = line:find("const%s+") or line:find("let%s+") or line:find("var%s+")
		if var_start then
			-- Find the equal sign '=' in the line after the variable declaration
			local equal_pos = line:find("=")
			if equal_pos then
				-- Move the cursor to the position of the equal sign
				vim.api.nvim_win_set_cursor(0, { i, equal_pos }) -- Move to the '=' sign

				-- Move cursor to the end of the variable name
				local var_end = line:sub(var_start, equal_pos - 1):match("%s*(%w+)%s*$")
				if var_end then
					local end_pos = var_start + #var_end - 1 -- Position at the end of the variable name
					vim.api.nvim_win_set_cursor(0, { i, end_pos })
				end
				return
			end
		end
	end
end

-- Key mapping
vim.api.nvim_set_keymap(
	"n",
	"<leader>jn",
	"<cmd>lua moveToEndOfNextVariableName()<CR>",
	{ noremap = true, silent = true }
)

--
--
--
--
--
--
--w:   comment out all console.log statements except the one at the current cursor position
function comment_all_console_logs_except_current()
	-- Get the line number of the current cursor position
	local current_line = vim.fn.line(".")
	-- Get all lines in the current buffer
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for i, line in ipairs(lines) do
		-- Match only lines with "console.log" and skip the current cursor line
		if line:match("console%.log") and i ~= current_line then
			lines[i] = "// " .. line -- Add "// " at the start of the line to comment it out
		end
	end

	-- Set the updated lines back in the buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

-- Keybinding to trigger the function with <space>jc
vim.keymap.set(
	"n",
	"<space>jc",
	"<cmd>lua comment_all_console_logs_except_current()<CR>",
	{ noremap = true, silent = true }
)
-- vim.keymap.set("n", "<space>jc", comment_all_console_logs_except_current, { noremap = true, silent = true })

--
--
--
--
--
--p: press console.log
-- Insert mode mapping for 'jsc'
vim.api.nvim_set_keymap("i", "<space>ji", "console.log(``)<Esc>hi", { noremap = true, silent = true })

-- Normal mode mapping for 'space ji'
vim.api.nvim_set_keymap("n", "<space>ji", "oconsole.log(``)<Esc>hi", { noremap = true, silent = true })

--h: copy the current word down
vim.api.nvim_set_keymap("i", "<space>jd", "<Esc>yiw<CR>O<C-o>p", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<space>jd", "yiw<CR>o<C-o>p", { noremap = true, silent = true })
--
--
--
--w: insert type with space jj
vim.api.nvim_set_keymap("n", "<space>jj", "otype Name= ;<Esc>bb viwc", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<space>jk", "type Name= ;<Esc>bb viwc", { noremap = true, silent = true })

--w: 07/11/2024 06:54 AM Thu GMT+6 Sharifpur, Gazipur, Dhaka
--
--
--w: change_current_window_panes_to_project_root function as a global function
--[[ function _G.change_current_window_panes_to_project_root()
	-- Determine the project root directory
	local project_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		project_root = vim.fn.getcwd() -- Fall back to the current working directory if not in a Git repo
	end

	-- Get the Tmux pane ID for the current Neovim pane
	local current_pane = vim.fn.systemlist("tmux display-message -p '#{pane_id}'")[1]

	-- Command to change all panes in the current Tmux window (except Neovim pane) to the project root
	local tmux_command = "tmux list-panes -F '#{pane_id}' | grep -v '"
		.. current_pane
		.. "' | xargs -I {} tmux send-keys -t {} 'cd "
		.. project_root
		.. " && clear' Enter"

	-- Execute the command
	vim.fn.system(tmux_command)
end ]]

function _G.change_current_window_panes_to_project_root()
	-- Step 1: Get current working directory in Neovim
	local project_root = vim.fn.getcwd()

	-- Step 2: Get current Tmux pane and window ID
	local current_pane = vim.fn.systemlist("tmux display-message -p '#{pane_id}'")[1]
	-- local window_index = vim.fn.systemlist("tmux display-message -p '#{window_index}'")[1]

	-- Step 3: Change all other panes in the current tmux window to Neovim's cwd
	local tmux_command = "tmux list-panes -F '#{pane_id}' | grep -v '"
		.. current_pane
		.. "' | xargs -I {} tmux send-keys -t {} 'cd "
		.. project_root
		.. " && clear' Enter"

	vim.fn.system(tmux_command)

	vim.fn.system("tmux select-layout -t 0 '8d8d,210x44,0,0[210x27,0,0,4,210x16,0,28{104x16,0,28,5,105x16,105,28,6}]'")
	vim.fn.system("tmux select-layout -t 2 '6520,210x44,0,0[210x28,0,0,7,210x15,0,29{104x15,0,29,8,105x15,105,29,9}]'")
	vim.fn.system(
		"tmux select-layout -t 3 '2ecf,210x44,0,0[210x32,0,0,10,210x11,0,33{107x11,0,33,11,102x11,108,33,12}]'"
	)
end

-- Map the function to `<space>ad` in normal mode
vim.api.nvim_set_keymap(
	"n",
	"<space>ad",
	":lua change_current_window_panes_to_project_root()<CR>",
	{ noremap = true, silent = true }
)
--w: 29/11/2024 06:43 PM Fri GMT+6 Sharifpur, Gazipur, Dhaka
-- vim.keymap.set({ "n", "x", "t", "o" }, ",", "<Cmd>HopChar1<CR>", { noremap = true, silent = true })
-- by go starting of the line and press a space
vim.keymap.set("n", "I", "I <Left>", { noremap = true, silent = true })
--
--
--
--
--
local function CopyGitRemote()
	-- Execute `git remote -v` and capture the output
	local git_remotes = vim.fn.systemlist("git remote -v")
	if vim.v.shell_error ~= 0 or #git_remotes == 0 then
		vim.notify("Failed to get git remotes. Ensure you're in a git repository.", vim.log.levels.ERROR)
		return
	end

	-- Extract the URL part (without 'origin', 'fetch', etc.)
	local remote_url = git_remotes[1]:match("git@[^%s]+")
	if not remote_url then
		vim.notify("Failed to extract remote URL.", vim.log.levels.ERROR)
		return
	end

	-- Copy the URL to the system clipboard
	vim.fn.setreg("+", remote_url) -- Copies to the system clipboard
	vim.notify("Copied git remote: " .. remote_url, vim.log.levels.INFO)
end

-- Bind the function to <space>ac
vim.keymap.set("n", "<space>ac", CopyGitRemote, { desc = "Copy git remote URL to clipboard" })
--
--
--
--
--
-- Universal to camelCase converter
-- Convert any text format to camelCase
local function to_camel_case(str)
	-- Replace separators with space
	str = str:gsub("[%-%._/]", " ")
	-- Add space before camelCase caps
	str = str:gsub("(%l)(%u)", "%1 %2")
	-- Lowercase everything
	str = str:lower()

	-- Split into words
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end

	-- Capitalize all except first
	for i = 2, #words do
		words[i] = words[i]:sub(1, 1):upper() .. words[i]:sub(2)
	end

	return table.concat(words, "")
end

-- Paste in normal mode
local function paste_camel_normal()
	local clipboard = vim.fn.getreg("+")
	local camel = to_camel_case(clipboard)
	vim.fn.setreg("+", camel)
	vim.api.nvim_feedkeys('"+p', "n", false)
end

-- Paste in insert mode
local function paste_camel_insert()
	local clipboard = vim.fn.getreg("+")
	local camel = to_camel_case(clipboard)
	vim.api.nvim_put({ camel }, "c", true, true)
end

-- Map in both modes
vim.keymap.set("n", "<leader>uc", paste_camel_normal, { noremap = true, silent = true })
vim.keymap.set("i", "<leader>uc", paste_camel_insert, { noremap = true, silent = true })
