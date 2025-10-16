vim.api.nvim_set_keymap("i", "jsv", "<Esc>:vsplit<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jsh", "<Esc>:split<CR>", { noremap = true, silent = true })
-- save file with kk while in insert mode
-- vim.api.nvim_set_keymap("i", "ll", "<Esc>:w<CR>a", { noremap = true, silent = true })
-- Map kk to backspace in insert mode
vim.api.nvim_set_keymap("i", "kk", "<BS>", { noremap = true, silent = true })

-- Map kj to delete the character under the cursor in insert mode
vim.api.nvim_set_keymap("i", "jk", "<Del>", { noremap = true, silent = true })

--t: Map Ctrl + z to undo
vim.api.nvim_set_keymap("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
-- Map Ctrl + b to redo (using Ctrl + o then Ctrl + r)
vim.api.nvim_set_keymap("i", "<C-s>", "<C-o><C-r>", { noremap = true, silent = true })
--
-- --  C-jkl in insert mode also work like normal mode c-hjkl
--
-- vim.api.nvim_set_keymap("i", "<C-h>", "<C-o><C-h><Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-h>", "<C-o><C-w>h<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<C-o><C-w>l<Esc>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<M-u>", "<C-o>o", { noremap = true, silent = true })
-- send c-o by pressing (')
vim.api.nvim_set_keymap("i", "<M-y>", "<C-o>O", { noremap = true, silent = true })

-- Map Alt-i in insert mode to run the function
-- copy line down like vs code
--t: normal mode: enter will create a new line in down
vim.api.nvim_set_keymap("n", "<CR>", "o<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-`>", "i`<Esc>", { noremap = true, silent = true })

--t: Map 'jj' and ESC  to escape and then write
vim.api.nvim_set_keymap("i", "jj", "<Esc>:w!<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "<Esc>", "<Esc>:w!<CR>", { noremap = true, silent = true })

--t: Function to insert formatted date and time
-- function InsertDateTime()
-- 	local date_time = os.date("%d/%m/%Y  %I:%M %p %a GMT+6  Sharifpur, Gazipur, Dhaka")
-- 	vim.api.nvim_put({ date_time }, "c", true, true)
-- end
-- --t: insert date
-- vim.api.nvim_set_keymap("n", "<leader>dt", "<cmd>lua InsertDateTime()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "jdt", "<cmd>lua InsertDateTime()<CR>", { noremap = true, silent = true })
--
--
--
--
--
--
--
--t: console.log by  space sc
--t: Console Log Variable
vim.api.nvim_set_keymap("n", "<space>sc", ":lua ConsoleLogVariable()<CR>", { noremap = true, silent = true })

function ConsoleLogVariable()
	local variable = vim.fn.expand("<cword>")
	local file = vim.fn.expand("%:t") -- Get the current file name
	local line_number = vim.fn.line(".") + 1 -- Get the current line number and add 1
	local log_statement = string.format("console.log(%s, '%s', %d);", variable, file, line_number)
	vim.api.nvim_put({ log_statement }, "l", true, true)
end

--
--
--
--
--
--
--
--
--
--t: ConsoleLogAbsolutePath
--
vim.api.nvim_set_keymap("n", "<space>si", ":lua ConsoleLogAbsolutePath()<CR>", { noremap = true, silent = true })

function ConsoleLogAbsolutePath()
	local variable = vim.fn.expand("<cword>")
	local file_path = vim.fn.expand("%:p") -- Get the absolute path of the current file
	local line_number = vim.fn.line(".") + 1 -- Get the current line number and add 1
	local log_statement = string.format("console.log(%s, '%s', %d);", variable, file_path, line_number)
	vim.api.nvim_put({ log_statement }, "l", true, true)
end

--
--
--
--
--
--
--
--
--

--
--
--
--
--
--
--
--t: Key mapping to run nodemon on the current file in the third tmux pane
vim.api.nvim_set_keymap("n", "<space>sk", ":lua RunNodemonInTmuxPane()<CR>", { noremap = true, silent = true })
--t: node mon start
-- function RunNodemonInTmuxPane()
-- 	-- Prompt the user for the pane number and immediately close the prompt
-- 	local pane_number = vim.fn.input("Enter the pane number: ")
-- 	vim.cmd("echo ''") -- Clear the input prompt from the command line
--
-- 	-- Get the absolute path of the current file
-- 	local file_path = vim.fn.expand("%:p")
--
-- 	-- Stop any running process in the specified pane by sending Ctrl+C
-- 	local stop_command = "tmux send-keys -t " .. pane_number .. " C-c"
-- 	vim.fn.system(stop_command)
--
-- 	-- Wait briefly to ensure the process is stopped
-- 	vim.wait(200)
--
-- 	-- Construct and send the nodemon command
-- 	local start_command = "tmux send-keys -t " .. pane_number .. ' "nodemon ' .. file_path .. '" C-m'
-- 	vim.fn.system(start_command)
--
-- 	-- Notify the user (optional)
-- 	vim.notify("Restarted nodemon in pane " .. pane_number .. " for file: " .. file_path)
-- end
--
function RunNodemonInTmuxPane()
	-- Prompt the user for the pane number and immediately close the prompt
	local pane_number = vim.fn.input("Enter the pane number: ")
	vim.cmd("echo ''") -- Clear the input prompt from the command line

	-- Get the absolute path of the current file
	local file_path = vim.fn.expand("%:p")

	-- Stop any running process in the specified pane by sending Ctrl+C
	local stop_command = "tmux send-keys -t " .. pane_number .. " C-c"
	vim.fn.system(stop_command)

	-- Wait briefly to ensure the process is stopped
	vim.wait(200)

	-- Clear the tmux pane before starting the new command
	local clear_command = "tmux send-keys -t " .. pane_number .. " C-l"
	vim.fn.system(clear_command)

	-- Wait briefly before running nodemon
	vim.wait(100)

	-- Construct and send the nodemon command
	local start_command = "tmux send-keys -t " .. pane_number .. ' "nodemon ' .. file_path .. '" C-m'
	vim.fn.system(start_command)

	-- Notify the user (optional)
	vim.notify("Restarted nodemon in pane " .. pane_number .. " for file: " .. file_path)
end

--
--
--
--
--
--
--
-- color console
vim.api.nvim_set_keymap("n", "<space>sd", ":lua ConsoleLogVariableWithColor()<CR>", { noremap = true, silent = true })
--t:  ConsoleLogVariableWithColor
function ConsoleLogVariableWithColor()
	local variable = vim.fn.expand("<cword>")
	local file = vim.fn.expand("%:t") -- Get the current file name
	local line_number = vim.fn.line(".") + 1 -- Get the current line number and add 1

	-- Define ANSI color codes for bold red
	local red_bold = "\27[1;31m"
	local reset = "\27[0m"

	-- Format the console.log statement with ANSI color codes
	local log_statement = string.format(
		'console.log(%s, "' .. red_bold .. "%s in %s at line %d" .. reset .. '");',
		variable,
		variable,
		file,
		line_number
	)

	-- Insert the log statement below the current line
	vim.api.nvim_put({ log_statement }, "l", true, true)
end

--t:
vim.api.nvim_set_keymap("n", "<space>sb", ":lua colorConsoleBrowser()<CR>", { noremap = true, silent = true })

--
--
--
--
--
function InsertDateTime()
	-- Get the current line text
	local current_line = vim.api.nvim_get_current_line()

	-- Determine the comment prefix based on the file type
	local filetype = vim.bo.filetype
	local comment_prefix

	if filetype == "javascript" or filetype == "typescript" then
		comment_prefix = "//w: " -- Changed from //t: to //w:
	elseif filetype == "python" then
		comment_prefix = "#w: " -- Changed from #t: to #w:
	else
		comment_prefix = "--w: " -- Default for other file types
	end

	-- Create the date and time string
	local date_time = os.date("%d/%m/%Y %I:%M %p %a GMT+6 Sharifpur, Gazipur, Dhaka")
	local formatted_date_time = comment_prefix .. date_time -- Combine the comment prefix and date/time

	-- Set the current line to the formatted date and time
	vim.api.nvim_set_current_line(formatted_date_time)
end

-- Mapping for normal mode
vim.api.nvim_set_keymap("n", "<leader>dt", "<cmd>lua InsertDateTime()<CR>", { noremap = true, silent = true })
-- Mapping for insert mode
vim.api.nvim_set_keymap("i", "jdt", "<cmd>lua InsertDateTime()<CR>", { noremap = true, silent = true })
