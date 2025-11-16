--w: ╭──────────── Block Start ────────────╮

--w: ╰───────────── Block End ─────────────╯

--w:(Start )╭──────────── create git repo and push to github  ────────────╮
--p: create public git repo with with  the current folder name or prompt and push to github => add readme.md with the project information
-- local function createGitRepoAndPushToGithub()
-- 	-- Get the current working directory
-- 	local cwd = vim.fn.getcwd()
--
-- 	-- Get the current date and time
-- 	local date_time = os.date("%d/%m/%Y %I:%M %p %a GMT+6")
--
-- 	-- Define the location
-- 	local location = "Sharifpur, Gazipur, Dhaka"
--
-- 	-- Default repository name to root directory name
-- 	local repo_name = vim.fn.fnamemodify(cwd, ":t")
-- 	local live_site = "http://shahjalal-mern.surge.sh"
-- 	local portfolio_github = "https://github.com/shahjalal-labs/shahjalal-portfolio-v2"
-- 	local portfolio_live = "http://shahjalal-labs.surge.sh"
-- 	local linkedin = "https://www.linkedin.com/in/shahjalal-labs/"
--
-- 	local facebook = "https://www.facebook.com/shahjalal.labs"
-- 	local twitter = "https://x.com/shahjalal_labs"
--
-- 	-- Prompt for repository name (non-blocking) with default
-- 	vim.ui.input({ prompt = "Enter the repository name: ", default = repo_name }, function(input)
-- 		repo_name = input or repo_name -- Use input if provided, otherwise use default
-- 		local github_url = "https://github.com/shahjalal-labs/" .. repo_name
--
-- 		-- Notify starting status
-- 		vim.cmd("redrawstatus")
-- 		vim.cmd("echo 'Initializing repository...'")
--
-- 		-- Prepare README.md content
--
-- 		local readme_content = string.format(
-- 			[[# 🌟 %s
--
-- ## 📂 Project Information
--
-- | 📝 **Detail**           | 📌 **Value**                                                              |
-- |------------------------|---------------------------------------------------------------------------|
-- | 🔗 **GitHub URL**       | [%s](%s)                                                                  |
-- | 🌐 **Live Site**        | [%s](%s)                                                                  |
-- | 💻 **Portfolio GitHub** | [%s](%s)                                                                  |
-- | 🌐 **Portfolio Live**   | [%s](%s)                                                                  |
-- | 📁 **Directory**        | `%s`                                                                      |
-- | 📅 **Created On**       | `%s`                                                                      |
-- | 📍 **Location**         | %s                                                                        |
-- | 💼 **LinkedIn**         | [%s](%s)                                                                  |
-- | 📘 **Facebook**         | [%s](%s)                                                                  |
-- | ▶️ **Twitter**          | [%s](%s)                                                                  |
--
-- ---
-- ### `Developer info:`
-- ![Developer Info:](https://i.ibb.co/kVR4YmrX/developer-Info-Github-Banner.png)
--
-- > 🚀
-- > 🧠
-- ]],
-- 			repo_name,
-- 			github_url,
-- 			github_url,
-- 			live_site,
-- 			live_site,
-- 			portfolio_github,
-- 			portfolio_github,
-- 			portfolio_live,
-- 			portfolio_live,
-- 			cwd,
-- 			date_time,
-- 			location,
-- 			linkedin,
-- 			linkedin,
-- 			facebook,
-- 			facebook,
-- 			twitter,
-- 			twitter
-- 		)
-- 		-- Check if README.md exists and append content at the top
-- 		local readme_file_path = "README.md"
-- 		local readme_content_with_existing = readme_content
--
-- 		if vim.fn.filereadable(readme_file_path) == 1 then
-- 			local existing_content = table.concat(vim.fn.readfile(readme_file_path), "\n")
-- 			readme_content_with_existing = readme_content .. "\n" .. existing_content
-- 		end
--
-- 		-- Write the README.md file
-- 		local readme_file = io.open(readme_file_path, "w")
-- 		readme_file:write(readme_content_with_existing)
-- 		readme_file:close()
--
-- 		-- Initialize Git repository and handle errors
-- 		local init_result = vim.fn.system("git init")
-- 		if vim.v.shell_error ~= 0 then
-- 			vim.notify("Error initializing Git repository: " .. init_result, vim.log.levels.ERROR)
-- 			return
-- 		end
--
-- 		local add_result = vim.fn.system("git add .")
-- 		if vim.v.shell_error ~= 0 then
-- 			vim.notify("Error adding files to Git: " .. add_result, vim.log.levels.ERROR)
-- 			return
-- 		end
--
-- 		local commit_result = vim.fn.system("git commit -m 'Initial commit'")
-- 		if vim.v.shell_error ~= 0 then
-- 			vim.notify("Error committing files to Git: " .. commit_result, vim.log.levels.ERROR)
-- 			return
-- 		end
--
-- 		local branch_result = vim.fn.system("git branch -M main")
-- 		if vim.v.shell_error ~= 0 then
-- 			vim.notify("Error renaming branch to main: " .. branch_result, vim.log.levels.ERROR)
-- 			return
-- 		end
--
-- 		-- Create GitHub repository and push, handle errors
-- 		local command = string.format("gh repo create %s --public --source=. --remote=origin --push", repo_name)
-- 		local result = vim.fn.system(command)
--
-- 		if vim.v.shell_error ~= 0 then
-- 			vim.notify("Error creating or pushing to GitHub repository: " .. result, vim.log.levels.ERROR)
-- 			return
-- 		end
--
-- 		-- Notify user about the successful creation and push of the repository
-- 		vim.cmd("redrawstatus")
-- 		vim.notify("Repository created and pushed successfully!", vim.log.levels.INFO)
--
-- 		-- Open the new GitHub repository in the browser
-- 		local open_url_command = string.format("xdg-open %s", github_url) -- For Linux; change as needed for other OSes.
-- 		os.execute(open_url_command)
--
-- 		-- Display result in the status line
-- 		vim.cmd("echo 'GitHub repository created and pushed!'")
-- 	end)
-- end
--
-- -- Map the function to <leader>gj
-- vim.keymap.set("n", "<leader>gj", createGitRepoAndPushToGithub, { noremap = true, silent = true })
--
--p: create git repo with with  the current folder name and push to github => add readme.md with the project information
local function createGitRepoAndPushToGithub()
	-- Get the current working directory
	local cwd = vim.fn.getcwd()

	-- Get the current date and time
	local date_time = os.date("%d/%m/%Y %I:%M %p %a GMT+6")

	-- Define the location
	local location = "Sharifpur, Gazipur, Dhaka"

	-- Default repository name to root directory name
	local repo_name = vim.fn.fnamemodify(cwd, ":t")
	local live_site = "http://shahjalal-mern.surge.sh"
	local portfolio_github = "https://github.com/shahjalal-labs/shahjalal-portfolio-v2"
	local portfolio_live = "http://shahjalal-labs.surge.sh"
	local linkedin = "https://www.linkedin.com/in/shahjalal-labs/"

	local facebook = "https://www.facebook.com/shahjalal.labs"
	local twitter = "https://x.com/shahjalal_labs"

	-- Prompt for repository name (non-blocking) with default
	vim.ui.input({ prompt = "Enter the repository name: ", default = repo_name }, function(input)
		repo_name = input or repo_name -- Use input if provided, otherwise use default

		-- Prompt for repository visibility
		vim.ui.input({
			prompt = "Make repository public? (Enter/yes = public, n/private = private): ",
			default = "public",
		}, function(visibility_input)
			local is_public = true -- default to public

			-- Check if user wants private repo
			if visibility_input and (visibility_input:lower() == "n" or visibility_input:lower() == "private") then
				is_public = false
			end

			local visibility_flag = is_public and "--public" or "--private"
			local github_url = "https://github.com/shahjalal-labs/" .. repo_name

			-- Notify starting status
			vim.cmd("redrawstatus")
			vim.cmd("echo 'Initializing repository...'")

			-- Prepare README.md content
			local readme_content = string.format(
				[[# 🌟 %s

## 📂 Project Information

| 📝 **Detail**           | 📌 **Value**                                                              |
|------------------------|---------------------------------------------------------------------------|
| 🔗 **GitHub URL**       | [%s](%s)                                                                  |
| 🌐 **Live Site**        | [%s](%s)                                                                  |
| 💻 **Portfolio GitHub** | [%s](%s)                                                                  |
| 🌐 **Portfolio Live**   | [%s](%s)                                                                  |
| 📁 **Directory**        | `%s`                                                                      |
| 📅 **Created On**       | `%s`                                                                      |
| 📍 **Location**         | %s                                                                        |
| 💼 **LinkedIn**         | [%s](%s)                                                                  |
| 📘 **Facebook**         | [%s](%s)                                                                  |
| ▶️ **Twitter**          | [%s](%s)                                                                  |
| 🔒 **Visibility**       | %s                                                                        |

---
### `Developer info:`
![Developer Info:](https://i.ibb.co/kVR4YmrX/developer-Info-Github-Banner.png)

> 🚀 
> 🧠 
]],
				repo_name,
				github_url,
				github_url,
				live_site,
				live_site,
				portfolio_github,
				portfolio_github,
				portfolio_live,
				portfolio_live,
				cwd,
				date_time,
				location,
				linkedin,
				linkedin,
				facebook,
				facebook,
				twitter,
				twitter,
				is_public and "**Public** 🌍" or "**Private** 🔒"
			)

			-- Check if README.md exists and append content at the top
			local readme_file_path = "README.md"
			local readme_content_with_existing = readme_content

			if vim.fn.filereadable(readme_file_path) == 1 then
				local existing_content = table.concat(vim.fn.readfile(readme_file_path), "\n")
				readme_content_with_existing = readme_content .. "\n" .. existing_content
			end

			-- Write the README.md file
			local readme_file = io.open(readme_file_path, "w")
			readme_file:write(readme_content_with_existing)
			readme_file:close()

			-- Initialize Git repository and handle errors
			local init_result = vim.fn.system("git init")
			if vim.v.shell_error ~= 0 then
				vim.notify("Error initializing Git repository: " .. init_result, vim.log.levels.ERROR)
				return
			end

			local add_result = vim.fn.system("git add .")
			if vim.v.shell_error ~= 0 then
				vim.notify("Error adding files to Git: " .. add_result, vim.log.levels.ERROR)
				return
			end

			local commit_result = vim.fn.system("git commit -m 'Initial commit'")
			if vim.v.shell_error ~= 0 then
				vim.notify("Error committing files to Git: " .. commit_result, vim.log.levels.ERROR)
				return
			end

			local branch_result = vim.fn.system("git branch -M main")
			if vim.v.shell_error ~= 0 then
				vim.notify("Error renaming branch to main: " .. branch_result, vim.log.levels.ERROR)
				return
			end

			-- Create GitHub repository and push, handle errors
			local command =
				string.format("gh repo create %s %s --source=. --remote=origin --push", repo_name, visibility_flag)
			local result = vim.fn.system(command)

			if vim.v.shell_error ~= 0 then
				vim.notify("Error creating or pushing to GitHub repository: " .. result, vim.log.levels.ERROR)
				return
			end

			-- Notify user about the successful creation and push of the repository
			vim.cmd("redrawstatus")
			local visibility_text = is_public and "public" or "private"
			vim.notify(
				visibility_text:sub(1, 1):upper()
					.. visibility_text:sub(2)
					.. " repository created and pushed successfully!",
				vim.log.levels.INFO
			)

			-- Open the new GitHub repository in the browser
			local open_url_command = string.format("xdg-open %s", github_url) -- For Linux; change as needed for other OSes.
			os.execute(open_url_command)

			-- Display result in the status line
			vim.cmd("echo 'GitHub " .. visibility_text .. " repository created and pushed!'")
		end)
	end)
end

-- Map the function to <leader>gj
vim.keymap.set(
	"n",
	"<leader>gj",
	createGitRepoAndPushToGithub,
	{ noremap = true, silent = true, desc = "Create Git repo (public/private) and push to it with README.md" }
)

--w:(End)╰───────────── create git repo and push to github ─────────────╯

--w: (start)╭──────────── GitPushFromNvimCommitPrompting ────────────╮
--t: git push from neovim with custom commit message prompting
function GitPushFromNvimCommitPrompting()
	-- Prompt for commit message
	local commit_message = vim.fn.input("Enter commit message: ")

	-- Ensure the commit message is not empty
	if commit_message == "" then
		print("Commit message cannot be empty. Aborting.")
		return
	end

	-- Execute the git commands sequentially
	vim.cmd("!git add .")
	vim.cmd("!git commit -m '" .. commit_message .. "'")
	vim.cmd("!git push")
end
vim.api.nvim_set_keymap(
	"n",
	"<space>aj",
	":lua GitPushFromNvimCommitPrompting()<CR>",
	{ noremap = true, silent = true }
)

--w: (end)  ╰──────────── GitPushFromNvimCommitPrompting ────────────╯
--
-- ╭──────────── Block Start ────────────╮
-- STEP 1: Generate smart commit message with file filtering
-- local function generate_git_summary()
-- 	local ignored_patterns = {
-- 		"%.env$",
-- 		"%.lock$",
-- 		"node_modules/",
-- 		"%.DS_Store$",
-- 	}
--
-- 	local function should_ignore(file)
-- 		for _, pattern in ipairs(ignored_patterns) do
-- 			if file:match(pattern) then
-- 				return true
-- 			end
-- 		end
-- 		return false
-- 	end
--
-- 	local git_diff = vim.fn.systemlist("git diff --cached --name-status")
-- 	if not git_diff or #git_diff == 0 then
-- 		return nil
-- 	end
--
-- 	local summary = {}
--
-- 	for _, line in ipairs(git_diff) do
-- 		local status, file = line:match("^(%a)%s+(.+)$")
-- 		if file and not should_ignore(file) then
-- 			if status == "A" then
-- 				table.insert(summary, "🆕 Added: " .. file)
-- 			elseif status == "M" then
-- 				table.insert(summary, "✏️ Updated: " .. file)
-- 			elseif status == "D" then
-- 				table.insert(summary, "🗑️ Removed: " .. file)
-- 			end
-- 		end
-- 	end
--
-- 	if #summary == 0 then
-- 		return nil
-- 	end
--
-- 	return table.concat(summary, " | ")
-- end
--
-- -- STEP 2: Git add + commit + push
-- local function intelligent_git_push()
-- 	local cwd = vim.fn.getcwd()
--
-- 	-- git add .
-- 	vim.fn.jobstart({ "bash", "-c", "cd " .. cwd .. " && git add ." }, {
-- 		on_exit = function()
-- 			local msg = generate_git_summary()
-- 			if not msg then
-- 				vim.notify("⚠️ Nothing to commit", vim.log.levels.INFO)
-- 				return
-- 			end
--
-- 			local cmd = string.format([[cd "%s" && git commit -m "%s" && git push]], cwd, msg)
--
-- 			vim.fn.jobstart({ "bash", "-c", cmd }, {
-- 				detach = true,
-- 				on_exit = function(_, code)
-- 					if code == 0 then
-- 						vim.notify("✅ Git pushed: " .. msg, vim.log.levels.INFO)
-- 					else
-- 						vim.notify("❌ Git push failed", vim.log.levels.ERROR)
-- 					end
-- 				end,
-- 			})
-- 		end,
-- 	})
-- end
--
-- -- STEP 3: Command
-- vim.api.nvim_create_user_command("GitSmartPush", function()
-- 	intelligent_git_push()
-- end, {})
--
-- -- STEP 4: Keybind <leader>gp
-- vim.keymap.set("n", "<leader>gb", intelligent_git_push, { desc = "💡 Git Smart Push" })
--
-- -- STEP 5: Auto push every 30 seconds (testing)
-- local timer = vim.loop.new_timer()
-- timer:start(0, 30000, vim.schedule_wrap(intelligent_git_push))
--
-- -- ╰───────────── Block End ─────────────╯

--w: (start)╭──────────── RunGitRemoteInTmuxPane ────────────╮
--p: run git remote -v from neovim , dynamically select the tmux pane number
function RunGitRemoteInTmuxPane()
	-- Prompt the user for the tmux pane number
	local pane_number = vim.fn.input("Enter the tmux pane number: "):gsub("%s+", "")

	if pane_number == "" then
		vim.notify("No pane number provided. Operation canceled.", vim.log.levels.ERROR)
		return
	end

	-- Stop any running process in the specified tmux pane
	local stop_command = "tmux send-keys -t " .. pane_number .. " C-c"
	vim.fn.system(stop_command)

	-- Wait briefly to ensure the process is stopped
	vim.wait(200)

	-- Clear the tmux pane before running the new command
	local clear_command = "tmux send-keys -t " .. pane_number .. " C-l"
	vim.fn.system(clear_command)

	-- Wait briefly before sending the git remote command
	vim.wait(100)

	-- Send the git remote -v command
	local git_command = "tmux send-keys -t " .. pane_number .. ' "git remote -v" C-m'
	vim.fn.system(git_command)

	-- Notify the user
	vim.notify("Ran `git remote -v` in tmux pane " .. pane_number, vim.log.levels.INFO)
end
-- Bind the function to a key combination
vim.keymap.set("n", "<leader>ar", RunGitRemoteInTmuxPane, { desc = "Run `git remote -v` in specified tmux pane" })

--w: (end)  ╰──────────── RunGitRemoteInTmuxPane ────────────╯

--
--
--w: (start)╭──────────── GhCloneView ────────────╮
vim.api.nvim_create_user_command("GhCloneView", function()
	local repo = vim.fn.system("wl-paste"):gsub("%s+", "")
	if repo == "" or not repo:match(".+/.+") then
		vim.notify("Invalid clipboard content: Expected 'username/repo'", vim.log.levels.ERROR)
		return
	end

	local name = repo:gsub("/", "-")
	local dir = "/tmp/ghrepo/" .. name

	if vim.fn.isdirectory(dir) == 1 then
		vim.notify("Repo already cloned: " .. dir, vim.log.levels.INFO)
	else
		vim.notify("Cloning: " .. repo, vim.log.levels.INFO)

		-- Clone using depth=1
		local cmd = string.format("git clone --depth=1 https://github.com/%s %s", repo, dir)
		local result = vim.fn.system(cmd)

		if vim.v.shell_error ~= 0 then
			vim.notify("Clone failed:\n" .. result, vim.log.levels.ERROR)
			return
		end
	end

	-- Create new tmux window and 3 panes
	local tmux = string.format(
		[[
    tmux new-window -n ghrepo -c %s \
      'nvim .' \; split-window -v -c %s \; split-window -h -c %s
  ]],
		dir,
		dir,
		dir
	)

	vim.fn.system(tmux)
	vim.notify("✅ Repo opened in tmux window!", vim.log.levels.INFO)
end, {})

vim.keymap.set("n", "<leader>gc", ":GhCloneView<CR>", { desc = "Clone GitHub repo from clipboard" })
--w:(end) ╰───────────── GhCloneView ─────────────╯
--
--

--w: (start) ╭──────────── Clone GitHub repo and open in tmux async ────────────╮
vim.api.nvim_create_user_command("GhCloneTmuxView", function()
	local repo = vim.fn.system("wl-paste"):gsub("%s+", "")
	if repo == "" or not repo:match(".+/.+") then
		vim.schedule(function()
			vim.notify("Invalid clipboard content: Expected 'username/repo'", vim.log.levels.ERROR)
		end)
		return
	end

	local name = repo:gsub("/", "-")
	local dir = "/tmp/ghrepo/" .. name

	local function run_tmux()
		local tmux_script = string.format(
			[[
      tmux new-window -d -n ghrepo -c %s 'nvim .' ; \
      tmux split-window -v -t ghrepo -c %s ; \
      tmux split-window -h -t ghrepo -c %s ; \
      sleep 0.1 ; \
      tmux select-layout -t ghrepo '%s' ; \
      tmux select-pane -t ghrepo.1 ; \
      tmux select-window -t ghrepo
    ]],
			dir,
			dir,
			dir,
			"8d8d,210x44,0,0[210x27,0,0,1,210x16,0,28{104x16,0,28,2,105x16,105,28,3}]"
		)

		vim.fn.jobstart(tmux_script, {
			on_exit = function(_, code)
				vim.schedule(function()
					if code == 0 then
						vim.notify("Tmux window opened and focused on pane 1", vim.log.levels.INFO)
					else
						vim.notify("Tmux command failed with exit code " .. code, vim.log.levels.ERROR)
					end
				end)
			end,
		})
	end

	if vim.fn.isdirectory(dir) == 1 then
		vim.schedule(function()
			vim.notify("Repo already cloned: " .. dir, vim.log.levels.INFO)
		end)
		run_tmux()
	else
		vim.schedule(function()
			vim.notify("Cloning: " .. repo, vim.log.levels.INFO)
		end)
		local clone_cmd = string.format("git clone --depth=1 https://github.com/%s %s", repo, dir)
		vim.fn.jobstart(clone_cmd, {
			on_exit = function(_, code)
				vim.schedule(function()
					if code == 0 then
						vim.notify("Clone successful!", vim.log.levels.INFO)
						run_tmux()
					else
						vim.notify("Clone failed with exit code: " .. code, vim.log.levels.ERROR)
					end
				end)
			end,
		})
	end
end, {})

vim.keymap.set("n", "<leader>ga", ":GhCloneTmuxView<CR>", { desc = "Clone GitHub repo and open in tmux async" })

--w:(end) ╰───────────── Clone GitHub repo and open in tmux async ─────────────╯
