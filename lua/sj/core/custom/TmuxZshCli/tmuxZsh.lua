-- ╭──────────── Block Start ────────────╮

-- ╰───────────── Block End ─────────────╯

--t: Function to backup dotfiles and push to Git
function backup_and_git_push()
	local backup_dir = "/mnt/fed/allDotfilesBackup"

	-- Run shell commands to back up the files
	vim.fn.system("mkdir -p " .. backup_dir)
	vim.fn.system("cp -r ~/.config/i3 " .. backup_dir .. "/i3")
	vim.fn.system("cp -r ~/.tmux.conf " .. backup_dir .. "/tmux.conf")
	vim.fn.system("cp -r ~/.zshrc " .. backup_dir .. "/zshrc")
	vim.fn.system("cp -r ~/.config/nvim " .. backup_dir .. "/nvim")
	vim.fn.system("cp -r /etc/keyd " .. backup_dir .. "/keyd")
	vim.fn.system("cp -r ~/.config/yazi " .. backup_dir .. "/yazi")
	vim.fn.system("cp -r /mnt/fed/zshScript " .. backup_dir)
	vim.fn.system("cp -r  " .. backup_dir)

	-- Prompt for the Git commit message
	local commit_message = vim.fn.input("Enter commit message: ")
	if commit_message == "" then
		print("Commit message cannot be empty. Aborting.")
		return
	end

	-- Git push operation within the target directory
	vim.fn.system("git -C " .. backup_dir .. " add .")
	vim.fn.system("git -C " .. backup_dir .. " commit -m '" .. commit_message .. "'")
	vim.fn.system("git -C " .. backup_dir .. " push")

	print("Backup and push completed successfully.")
end

vim.api.nvim_set_keymap("n", "<leader>ab", ":lua backup_and_git_push()<CR>", { noremap = true, silent = true })
--
--
--
--
--
--
--
--t: Function to open the current project root in VS Code
function open_project_in_vscode()
	-- Get the current project root directory
	local project_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

	-- Check if inside a Git repository
	if project_root == "" then
		print("Not in a Git repository.")
		return
	end

	-- Open VS Code in the project root
	vim.fn.system("code " .. project_root)
	print("Opening project in VS Code: " .. project_root)
end
vim.api.nvim_set_keymap("n", "<leader>av", ":lua open_project_in_vscode()<CR>", { noremap = true, silent = true })
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
vim.api.nvim_set_keymap("n", "<space>ao", ":lua SetNvimTreeRootToCursor()<CR>", { noremap = true, silent = true })
function SetNvimTreeRootToCursor()
	local api = require("nvim-tree.api")

	-- Get the node at the current cursor location
	local node = api.tree.get_node_under_cursor()

	if node and node.type == "directory" then
		-- Change Neovim root to the current directory under the cursor
		api.tree.change_root_to_node(node)

		-- Close the parent node
		api.node.navigate.parent_close(node)

		-- Optional: Center the cursor
		vim.cmd("normal! zz")

		-- Get the current directory path
		local new_root = node.absolute_path

		-- Update all Tmux panes except the Neovim pane to the new directory
		SetTmuxPanesDir(new_root)
	else
		print("Please place the cursor on a directory node to set it as the root.")
	end
end

function SetTmuxPanesDir(new_root)
	-- Get the ID of the current Tmux window
	local current_pane = vim.fn.systemlist("tmux display-message -p '#{pane_id}'")[1]
	local panes = vim.fn.systemlist("tmux list-panes -F '#{pane_id}'")

	-- Iterate through each pane in the current Tmux window
	for _, pane in ipairs(panes) do
		if pane ~= current_pane then
			-- Send the command to change directory to the other panes
			vim.fn.system("tmux send-keys -t " .. pane .. " 'cd " .. new_root .. "' C-m")
		end
	end
end

--
-- w: ╭──────────── Block Start ────────────╮
function SendAndOpenSurgeSite()
	vim.ui.input({ prompt = "Enter tmux pane number (default 2): " }, function(input)
		local pane = (input == nil or input == "") and "2" or input

		local cmd =
			'bun run build && cp dist/index.html dist/200.html && surge ./dist && xdg-open "http://$(cat public/CNAME)"'
		local tmux_cmd = string.format("tmux send-keys -t %s '%s' Enter", pane, cmd)

		vim.fn.system(tmux_cmd)
		print("🚀 Build, publish, and open triggered on tmux pane " .. pane)
	end)
end

vim.api.nvim_set_keymap("n", "<leader>ta", ":lua SendAndOpenSurgeSite()<CR>", { noremap = true, silent = true })
-- w: ╰───────────── Block End ─────────────╯
