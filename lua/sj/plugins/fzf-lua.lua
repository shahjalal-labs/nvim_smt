-- return {
-- 	"ibhagwan/fzf-lua",
-- 	requires = "nvim-lua/plenary.nvim",
-- 	config = function()
-- 		require("fzf-lua").setup({})
--
-- 		vim.keymap.set("n", "<leader>ag", function()
-- 			-- Run `gh repo list` to fetch repositories and use fzf-lua for selection
-- 			local repos =
-- 				vim.fn.systemlist("gh repo list Apollo-Level2-Web-Dev --json name --jq '.[].name' --limit 200")
-- 			if #repos == 0 then
-- 				print("No repositories found.")
-- 				return
-- 			end
--
-- 			-- Use fzf-lua to select a repository
-- 			require("fzf-lua").fzf_exec(repos, {
-- 				prompt = "Select a repo: ",
-- 				actions = {
-- 					-- Default action: Copy repo name to clipboard
-- 					["default"] = function(selected)
-- 						vim.fn.system("echo -n " .. selected[1] .. " | xclip -selection clipboard")
-- 					end,
-- 					-- Ctrl-o: Open the repo in the browser
-- 					["ctrl-o"] = function(selected)
-- 						vim.fn.system("gh repo view Apollo-Level2-Web-Dev/" .. selected[1] .. " --web")
-- 					end,
-- 					-- Ctrl-r: Clone the selected repo
-- 					["ctrl-r"] = function(selected)
-- 						vim.fn.system("git clone https://github.com/Apollo-Level2-Web-Dev/" .. selected[1])
-- 					end,
-- 				},
-- 			})
-- 		end, { desc = "Open GitHub Repo Manager" })
-- 	end,
-- }
--t: below added for running zsh history command

return {
	"ibhagwan/fzf-lua",
	requires = "nvim-lua/plenary.nvim",
	config = function()
		require("fzf-lua").setup({})

		-- Existing GitHub Repo Manager functionality
		vim.keymap.set("n", "<leader>ag", function()
			-- Run `gh repo list` to fetch repositories and use fzf-lua for selection
			local repos =
				vim.fn.systemlist("gh repo list Apollo-Level2-Web-Dev --json name --jq '.[].name' --limit 200")
			if #repos == 0 then
				print("No repositories found.")
				return
			end

			-- Use fzf-lua to select a repository
			require("fzf-lua").fzf_exec(repos, {
				prompt = "Select a repo: ",
				actions = {
					-- Default action: Copy repo name to clipboard
					["default"] = function(selected)
						vim.fn.system("echo -n " .. selected[1] .. " | xclip -selection clipboard")
					end,
					-- Ctrl-o: Open the repo in the browser
					["ctrl-o"] = function(selected)
						vim.fn.system("gh repo view Apollo-Level2-Web-Dev/" .. selected[1] .. " --web")
					end,
					-- Ctrl-r: Clone the selected repo
					["ctrl-r"] = function(selected)
						vim.fn.system("git clone https://github.com/Apollo-Level2-Web-Dev/" .. selected[1])
					end,
				},
			})
		end, { desc = "Open GitHub Repo Manager" })

		-- Zsh History functionality with tmux pane number prompt
		vim.keymap.set("n", "<leader>ch", function()
			-- Read Zsh history from the file
			local history_file = vim.fn.expand("~/.zsh_history")
			local history = vim.fn.readfile(history_file)

			if #history == 0 then
				print("No command history found.")
				return
			end

			-- Prompt for tmux pane number
			local pane_number = vim.fn.input("Enter tmux pane number: ")
			if pane_number == "" then
				print("No pane number provided.")
				return
			end

			-- Use fzf-lua to select a Zsh command
			require("fzf-lua").fzf_exec(history, {
				prompt = "Select Zsh command: ",
				actions = {
					-- Default action: Run the selected command in the specified tmux pane
					["default"] = function(selected)
						local command = selected[1]
						-- Send the command to the selected tmux pane
						vim.fn.system("tmux send-keys -t " .. pane_number .. " '" .. command .. "' C-m")
						print("Running: " .. command .. " in pane " .. pane_number)
					end,
				},
			})
		end, { desc = "Run command from Zsh history in tmux pane" })
	end,
}
