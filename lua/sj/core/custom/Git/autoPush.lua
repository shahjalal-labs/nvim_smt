--w: (start)╭────────────  auto push after every 7 mnts ────────────╮
--p: updated  for adding multiple remote like :
-- labs    git@github.com:shahjalal-labs/flo_backend.git (fetch)
-- origin  git@github.com:smTech24-official/nasonrice_backend.git (fetch)

local uv = vim.loop
local active_git_roots = {}

-- Helper: shorten path
local function get_short_path(filepath)
	local parts = {}
	for part in filepath:gmatch("[^/\\]+") do
		table.insert(parts, part)
	end
	local len = #parts
	if len >= 2 then
		return parts[len - 1] .. "/" .. parts[len]
	elseif len == 1 then
		return parts[1]
	else
		return filepath
	end
end

-- Helper: ignore patterns
local function should_ignore(file)
	local ignore_patterns = { "%.lock$", "^%.env", "^node_modules/" }
	for _, pat in ipairs(ignore_patterns) do
		if file:match(pat) then
			return true
		end
	end
	return false
end

-- Generate commit summary based on git diff
local function generate_git_summary(git_root)
	local status_lines = vim.fn.systemlist("git -C " .. git_root .. " diff --cached --name-status")
	if not status_lines or #status_lines == 0 then
		return nil
	end

	local added, modified, deleted = {}, {}, {}

	for _, line in ipairs(status_lines) do
		local status, file = line:match("^(%w)%s+(.+)$")
		if status and file and not should_ignore(file) then
			local short_file = get_short_path(file)
			if status == "A" then
				table.insert(added, short_file)
			elseif status == "M" then
				table.insert(modified, short_file)
			elseif status == "D" then
				table.insert(deleted, short_file)
			end
		end
	end

	local parts = {}
	if #added > 0 then
		table.insert(parts, "feat: Added " .. table.concat(added, ", "))
	end
	if #modified > 0 then
		table.insert(parts, "refactor: Updated " .. table.concat(modified, ", "))
	end
	if #deleted > 0 then
		table.insert(parts, "chore: Removed " .. table.concat(deleted, ", "))
	end

	if #parts == 0 then
		return nil
	end
	return table.concat(parts, " | ")
end

-- Validate repo
local function is_valid_repo(git_root)
	local remotes = vim.fn.systemlist("git -C " .. git_root .. " remote -v")
	for _, remote in ipairs(remotes) do
		if remote:match("github.com[:/]+shahjalal%-labs/") then
			return true
		end
	end
	return false
end

-- Link or create GitHub issues
local function link_github_issues(git_root, commit_msg)
	for issue_num in commit_msg:gmatch("#(%d+)") do
		local cmd = string.format('gh issue comment %s --body "%s"', issue_num, commit_msg)
		vim.fn.system(cmd)
		vim.notify("🔗 Linked commit to issue #" .. issue_num, vim.log.levels.INFO)
	end

	if commit_msg:match("issue:") then
		local title = commit_msg:gsub("issue:", ""):gsub('"', '\\"')
		local cmd = string.format('gh issue create --title "%s" --body "Created from commit in %s"', title, git_root)
		vim.fn.system(cmd)
		vim.notify("🆕 Created GitHub issue from commit message", vim.log.levels.INFO)
	end
end

-- Intelligent Git push (multi-remote)
--w: (start)╭──────────── intelligent_git_push ────────────╮
--[[ local function intelligent_git_push(git_root)
	if not git_root or git_root == "" then
		return
	end
	if not is_valid_repo(git_root) then
		vim.schedule(function()
			vim.notify("🚫 Not a shahjalal-labs repo: " .. git_root, vim.log.levels.WARN)
		end)
		return
	end

	vim.fn.jobstart({ "git", "-C", git_root, "add", "." }, {
		on_exit = function()
			local diff = vim.fn.system("git -C " .. git_root .. " diff --cached --shortstat")
			local insertions = tonumber(diff:match("(%d+) insertion")) or 0
			local deletions = tonumber(diff:match("(%d+) deletion")) or 0
			if insertions + deletions < 17 then
				vim.schedule(function()
					vim.notify("⏸️ Skipped push — changes less than 17 LOC: " .. git_root, vim.log.levels.INFO)
				end)
				return
			end

			local commit_msg = generate_git_summary(git_root)
			if not commit_msg then
				vim.schedule(function()
					vim.notify("⏸️ Nothing to commit in " .. git_root, vim.log.levels.INFO)
				end)
				return
			end

			-- Link GitHub issues before commit
			link_github_issues(git_root, commit_msg)

			-- Detect all push remotes (GitHub ones)
			local remote_lines = vim.fn.systemlist("git -C " .. git_root .. " remote -v")
			local remotes_to_push = {}
			for _, line in ipairs(remote_lines) do
				local name, url = line:match("^(%S+)%s+(%S+)%s+%(push%)")
				if name and url and url:match("github%.com") then
					remotes_to_push[name] = true
				end
			end
			if vim.tbl_isempty(remotes_to_push) then
				remotes_to_push["origin"] = true
			end

			-- Commit once
			local commit_cmd = string.format('cd "%s" && git commit -m "%s"', git_root, commit_msg)
			local commit_code = os.execute(commit_cmd)
			if commit_code ~= 0 then
				vim.notify("❌ Commit failed in " .. git_root, vim.log.levels.ERROR)
				return
			end

			-- Push to all remotes sequentially
			for remote, _ in pairs(remotes_to_push) do
				local push_cmd = string.format('cd "%s" && git push %s HEAD', git_root, remote)
				vim.fn.jobstart({ "bash", "-c", push_cmd }, {
					on_exit = function(_, code)
						vim.schedule(function()
							if code == 0 then
								vim.notify("✅ Pushed to remote: " .. remote, vim.log.levels.INFO)
							else
								vim.notify("❌ Push failed for remote: " .. remote, vim.log.levels.ERROR)
							end
						end)
					end,
				})
			end

			-- Create GitHub release once
			local release_cmd = string.format(
				'gh release create "release-%s" --title "New Release %s" --notes "%s"',
				os.date("%Y%m%d%H%M%S"),
				os.date("%Y-%m-%d %H:%M:%S"),
				commit_msg
			)
			vim.fn.system(release_cmd)
		end,
	})
end ]]

-- Modified intelligent_git_push with configurable minimum LOC
local function intelligent_git_push(git_root, min_loc)
	min_loc = min_loc or 17 -- Default to 17 if not provided

	if not git_root or git_root == "" then
		return
	end
	if not is_valid_repo(git_root) then
		vim.schedule(function()
			vim.notify("🚫 Not a shahjalal-labs repo: " .. git_root, vim.log.levels.WARN)
		end)
		return
	end

	vim.fn.jobstart({ "git", "-C", git_root, "add", "." }, {
		on_exit = function()
			local diff = vim.fn.system("git -C " .. git_root .. " diff --cached --shortstat")
			local insertions = tonumber(diff:match("(%d+) insertion")) or 0
			local deletions = tonumber(diff:match("(%d+) deletion")) or 0
			if insertions + deletions < min_loc then
				vim.schedule(function()
					vim.notify(
						"⏸️ Skipped push — changes less than " .. min_loc .. " LOC: " .. git_root,
						vim.log.levels.INFO
					)
				end)
				return
			end

			-- ... rest of your existing function remains the same ...
			local commit_msg = generate_git_summary(git_root)
			if not commit_msg then
				vim.schedule(function()
					vim.notify("⏸️ Nothing to commit in " .. git_root, vim.log.levels.INFO)
				end)
				return
			end

			-- Link GitHub issues before commit
			link_github_issues(git_root, commit_msg)

			-- Detect all push remotes (GitHub ones)
			local remote_lines = vim.fn.systemlist("git -C " .. git_root .. " remote -v")
			local remotes_to_push = {}
			for _, line in ipairs(remote_lines) do
				local name, url = line:match("^(%S+)%s+(%S+)%s+%(push%)")
				if name and url and url:match("github%.com") then
					remotes_to_push[name] = true
				end
			end
			if vim.tbl_isempty(remotes_to_push) then
				remotes_to_push["origin"] = true
			end

			-- Commit once
			local commit_cmd = string.format('cd "%s" && git commit -m "%s"', git_root, commit_msg)
			local commit_code = os.execute(commit_cmd)
			if commit_code ~= 0 then
				vim.notify("❌ Commit failed in " .. git_root, vim.log.levels.ERROR)
				return
			end

			-- Push to all remotes sequentially
			for remote, _ in pairs(remotes_to_push) do
				local push_cmd = string.format('cd "%s" && git push %s HEAD', git_root, remote)
				vim.fn.jobstart({ "bash", "-c", push_cmd }, {
					on_exit = function(_, code)
						vim.schedule(function()
							if code == 0 then
								vim.notify("✅ Pushed to remote: " .. remote, vim.log.levels.INFO)
							else
								vim.notify("❌ Push failed for remote: " .. remote, vim.log.levels.ERROR)
							end
						end)
					end,
				})
			end

			-- Create GitHub release once
			local release_cmd = string.format(
				'gh release create "release-%s" --title "New Release %s" --notes "%s"',
				os.date("%Y%m%d%H%M%S"),
				os.date("%Y-%m-%d %H:%M:%S"),
				commit_msg
			)
			vim.fn.system(release_cmd)
		end,
	})
end
--w: (end)  ╰──────────── intelligent_git_push ────────────╯

-- Timer logic
local function start_git_timer(git_root)
	if active_git_roots[git_root] then
		return
	end

	local timer = uv.new_timer()
	timer:start(
		5000,
		420000, -- 7 mins
		vim.schedule_wrap(function()
			intelligent_git_push(git_root)
		end)
	)

	active_git_roots[git_root] = timer
	vim.notify("⏳ Started auto Git push timer for: " .. git_root, vim.log.levels.INFO)
end

-- Auto setup
local function setup_auto_git_push()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if not git_root or git_root == "" then
		return
	end
	start_git_timer(git_root)
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = setup_auto_git_push,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = setup_auto_git_push,
})

vim.api.nvim_create_user_command("GitSmartPush", function()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	intelligent_git_push(git_root)
end, {})

-- p:  Manual intelligent Git push
vim.keymap.set("n", "<leader>gb", function()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	intelligent_git_push(git_root)
end, { desc = "Manual intelligent Git push" })
--w: (end)  ╰──────────── auto push after every 7 mnts  ────────────╯
