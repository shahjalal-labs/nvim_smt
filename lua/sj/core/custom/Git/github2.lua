--p: ╭──────────── Block Start ────────────╮

--p: ╰───────────── Block End ─────────────╯

--p: ╭──────────── Block Start ────────────╮
local function copy_github_url()
	-- Get the origin URL from git config
	local handle = io.popen("git -C " .. vim.fn.getcwd() .. " config --get remote.origin.url")
	if not handle then
		print("Not a git repository or no origin remote")
		return
	end
	local url = handle:read("*a"):gsub("%s+", "")
	handle:close()

	if url == "" then
		print("No remote origin URL found")
		return
	end

	-- Normalize URL: convert SSH to HTTPS or keep HTTPS
	local https_url
	if url:match("^git@") then
		-- Convert ssh: git@github.com:user/repo.git => https://github.com/user/repo
		https_url = url:gsub("^git@", "https://"):gsub(":", "/"):gsub("%.git$", "")
	else
		-- HTTPS url - remove trailing .git if any
		https_url = url:gsub("%.git$", "")
	end

	-- Copy to system clipboard (using vim.fn.setreg)
	vim.fn.setreg("+", https_url)
	print("Copied GitHub URL to clipboard: " .. https_url)
end

vim.keymap.set("n", "<leader>gy", copy_github_url, { desc = "Copy current repo GitHub URL" })
--p: ╰───────────── Block End ─────────────╯

--p: ╭──────────── Block Start ────────────╮
-- Open the current repository in the browser
vim.keymap.set("n", "<leader>gm", ":!gh repo view --web<CR>", { noremap = true, silent = true })
--p: ╰───────────── Block End ─────────────╯
--
--p: ╭──────────── Block Start ────────────╮
local function show_github_contrib_today()
	local date = os.date("%Y-%m-%d")
	local cmd = table.concat({
		"gh api graphql -f query='query { viewer { contributionsCollection { contributionCalendar { weeks { contributionDays { date contributionCount } } } } } }' | jq -r '.data.viewer.contributionsCollection.contributionCalendar.weeks[] | .contributionDays[] | select(.date == \""
			.. date
			.. '") | "📆 \\(.date): 🔥 \\(.contributionCount) contributions"\'',
	}, " ")

	vim.cmd("vsplit | terminal " .. cmd)
end

vim.keymap.set("n", "<leader>gg", show_github_contrib_today, {
	noremap = true,
	silent = true,
	desc = "📈 Show today's GitHub contributions",
})

--p: ╰───────────── Block End ─────────────╯
--p: ╭──────────── Block Start ────────────╮
local function shell(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return ""
	end
	local result = handle:read("*a")
	handle:close()
	return vim.trim(result)
end

local function format_am_pm(time_str)
	local hour, min = time_str:match("(%d+):(%d+)")
	hour = tonumber(hour)
	local am_pm = hour < 12 and "AM" or "PM"
	if hour == 0 then
		hour = 12
	elseif hour > 12 then
		hour = hour - 12
	end
	return string.format("%02d:%s %s", hour, min, am_pm)
end

local function get_today_date()
	return os.date("%d-%m-%y")
end

local function get_commit_times()
	local first = shell("git log --since=midnight --pretty=format:'%ad' --date=format:'%H:%M' | tail -1"):gsub("'", "")
	local last = shell("git log --since=midnight --pretty=format:'%ad' --date=format:'%H:%M' | head -1"):gsub("'", "")
	return format_am_pm(first), format_am_pm(last)
end

local function get_today_commit_count()
	return tonumber(shell("git rev-list --count --since=midnight HEAD")) or 0
end

local function get_weekly_contributions()
	local results = {}
	for i = 1, 7 do
		local date = os.date("%d-%m-%y", os.time() - i * 86400)
		local count = tonumber(
			shell(
				"git rev-list --count --since='"
					.. i
					.. " days ago midnight' --until='"
					.. (i - 1)
					.. " days ago midnight' HEAD"
			)
		) or 0
		local icon = count >= 30 and "🟠" or count >= 15 and "🟡" or count >= 5 and "🟢" or "⚪"
		table.insert(results, string.format("%s   %s %d contributions", date, icon, count))
	end
	return results
end

local function get_repos_created_today()
	local today = os.date("%Y-%m-%d")
	local cmd = [[gh repo list --limit 100 --json name,visibility,createdAt | jq -r '.[] | select(.createdAt | startswith("]]
		.. today
		.. [[")).name + " (" + .visibility + ")"']]
	local list = shell(cmd)
	local lines = {}
	for repo in list:gmatch("[^\r\n]+") do
		table.insert(lines, "- " .. repo)
	end
	return #lines > 0 and lines or { "- None" }
end

local function get_commit_per_repo_today()
	local cmd = [[find . -type d -name .git | sed 's|/\.git||' | while read repo; do
		cd "$repo" || continue
		count=$(git rev-list --count --since=midnight HEAD 2>/dev/null)
		name=$(basename "$repo")
		if [ "$count" -gt 0 ]; then echo "- $name → $count commits"; fi
		cd - >/dev/null
	done]]
	local result = shell(cmd)
	local lines = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return #lines > 0 and lines or { "- None" }
end

local function get_pushed_repos_today()
	local cmd = [[find . -type d -name .git | sed 's|/\.git||' | while read repo; do
		cd "$repo" || continue
		last_push=$(git log -1 --pretty=format:'%cd' --date=format:'%Y-%m-%d' 2>/dev/null)
		name=$(basename "$repo")
		if [ "$last_push" = "$(date +%Y-%m-%d)" ]; then echo "- $name"; fi
		cd - >/dev/null
	done]]
	local result = shell(cmd)
	local lines = {}
	for line in result:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return #lines > 0 and lines or { "- None" }
end

local function get_open_prs()
	local cmd =
		[[gh pr list --limit 10 --json number,title,repository | jq -r '.[] | "- [" + .repository.name + "/#" + (.number|tostring) + "] " + .title']]
	local list = shell(cmd)
	local lines = {}
	for line in list:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return #lines > 0 and lines or { "- None" }
end

local function show_github_summary()
	local date = get_today_date()
	local first_commit, last_commit = get_commit_times()
	local today_commits = get_today_commit_count()

	local lines = {
		string.format(
			"📆 %s | 🕒 First Commit: %s → 🕕 Last Commit: %s → 🔥 %d contributions",
			date,
			first_commit,
			last_commit,
			today_commits
		),
		"",
		"🗓️ Weekly Contribution Summary (before today ↓)",
	}

	vim.list_extend(lines, get_weekly_contributions())
	table.insert(lines, "")
	table.insert(lines, "📦 Repos Created Today:")
	vim.list_extend(lines, get_repos_created_today())
	table.insert(lines, "")
	table.insert(lines, "🔢 Commits Per Repo:")
	vim.list_extend(lines, get_commit_per_repo_today())
	table.insert(lines, "")
	table.insert(lines, "🚀 Pushed To:")
	vim.list_extend(lines, get_pushed_repos_today())
	table.insert(lines, "")
	table.insert(lines, "🔗 Open Pull Requests:")
	vim.list_extend(lines, get_open_prs())

	-- Create floating window
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = 90
	local height = #lines + 2
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	}

	vim.api.nvim_open_win(buf, true, win_opts)

	-- Copy to clipboard
	vim.fn.setreg("+", table.concat(lines, "\n"))
	print("📋 Copied GitHub summary to clipboard!")
end

vim.keymap.set("n", "<leader>gz", show_github_summary, {
	noremap = true,
	silent = true,
	desc = "🧾 GitHub Real-Time Summary",
})
--p: ╰───────────── Block End ─────────────╯
--p: ╭──────────── Block Start ────────────╮

--p: ╰───────────── Block End ─────────────╯
--p: ╭──────────── Block Start ────────────╮

--p: ╰───────────── Block End ─────────────╯
--p: ╭──────────── Block Start ────────────╮

--p: ╰───────────── Block End ─────────────╯
