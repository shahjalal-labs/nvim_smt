--p: ╭──────────── copy_github_url ────────────╮
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
--p: ╰───────────── copy_github_url ─────────────╯

--
--p: ╭──────────── show_github_contrib_today ────────────╮
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

--p: ╰───────────── show_github_contrib_today─────────────╯
--
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

--p: ╭──────────── enhanced_github_contributions ────────────╮
local function enhanced_github_contributions()
	local date = os.date("%Y-%m-%d")
	local current_year = os.date("%Y")
	local current_month = os.date("%Y-%m")

	-- Enhanced GraphQL query to get more data
	local query = [[
{
  viewer {
    login
    contributionsCollection(from: "%s-01-01T00:00:00Z", to: "%s-12-31T23:59:59Z") {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
            color
          }
        }
      }
      contributionYears
      totalCommitContributions
      totalIssueContributions
      totalPullRequestContributions
      totalPullRequestReviewContributions
      totalRepositoryContributions
      restrictedContributionsCount
    }
  }
}
    ]]

	local formatted_query = string.format(query, current_year, current_year)
	local cmd = string.format([[gh api graphql -f query='%s']], formatted_query)

	local handle = io.popen(cmd)
	if not handle then
		vim.notify("❌ Failed to execute GitHub CLI command", vim.log.levels.ERROR)
		return
	end

	local result = handle:read("*a")
	handle:close()

	local ok, json_data = pcall(vim.fn.json_decode, result)
	if not ok or not json_data then
		vim.notify("❌ Failed to parse GitHub API response", vim.log.levels.ERROR)
		return
	end

	local data = json_data.data.viewer.contributionsCollection
	local username = json_data.data.viewer.login

	-- Calculate metrics
	local today_contributions = 0
	local current_streak = 0
	local longest_streak = 0
	local month_contributions = 0
	local year_contributions = data.contributionCalendar.totalContributions
	local streak_active = true
	local temp_streak = 0
	local longest_temp_streak = 0
	local biggest_day_this_month = { date = "", count = 0 }
	local biggest_day_this_year = { date = "", count = 0 }
	local all_days = {}

	-- Process all contribution days
	for _, week in ipairs(data.contributionCalendar.weeks) do
		for _, day in ipairs(week.contributionDays) do
			table.insert(all_days, day)

			-- Today's contributions
			if day.date == date then
				today_contributions = day.contributionCount
			end

			-- Month contributions
			if day.date:sub(1, 7) == current_month then
				month_contributions = month_contributions + day.contributionCount
				if day.contributionCount > biggest_day_this_month.count then
					biggest_day_this_month = { date = day.date, count = day.contributionCount }
				end
			end

			-- Year contributions and streaks
			if day.contributionCount > 0 then
				temp_streak = temp_streak + 1
				if temp_streak > longest_temp_streak then
					longest_temp_streak = temp_streak
				end

				-- Check if this is part of current streak (consecutive up to today)
				local day_time = os.time({
					year = tonumber(day.date:sub(1, 4)),
					month = tonumber(day.date:sub(6, 7)),
					day = tonumber(day.date:sub(9, 10)),
				})
				local today_time = os.time()
				local days_diff = os.difftime(today_time, day_time) / (24 * 60 * 60)

				if days_diff <= current_streak then
					current_streak = current_streak + 1
				elseif days_diff == 1 then
					current_streak = 2
				end

				-- Find biggest day of year
				if day.contributionCount > biggest_day_this_year.count then
					biggest_day_this_year = { date = day.date, count = day.contributionCount }
				end
			else
				temp_streak = 0
			end
		end
	end

	longest_streak = longest_temp_streak

	-- Create a nice display buffer
	local buf = vim.api.nvim_create_buf(false, true)
	local width = 60
	local height = 25
	local row = (vim.o.lines - height) / 2
	local col = (vim.o.columns - width) / 2

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Prepare content
	local lines = {
		"🚀 GitHub Contributions Dashboard",
		" ",
		"👤 User: @" .. username,
		"📅 Today: " .. date,
		" ",
		"📊 TODAY'S CONTRIBUTIONS",
		"  🔥 " .. today_contributions .. " contributions",
		" ",
		"🏆 STREAKS",
		"  ⚡ Current Streak: " .. current_streak .. " days",
		"  🏅 Longest Streak: " .. longest_streak .. " days",
		" ",
		"📈 OVERVIEW",
		"  📦 This Month: " .. month_contributions .. " contributions",
		"  🗓️  This Year: " .. year_contributions .. " contributions",
		"  💾 Total Commits: " .. data.totalCommitContributions,
		"  🐛 Total Issues: " .. data.totalIssueContributions,
		"  🔀 Total PRs: " .. data.totalPullRequestContributions,
		"  👀 Total PR Reviews: " .. data.totalPullRequestReviewContributions,
		" ",
		"🎯 PEAK PERFORMANCE",
		"  📅 This Month: " .. biggest_day_this_month.count .. " on " .. biggest_day_this_month.date,
		"  🏆 This Year: " .. biggest_day_this_year.count .. " on " .. biggest_day_this_year.date,
		" ",
		"🎮 QUICK ACTIONS",
		"  1. 🔄 Refresh Data   2. 📊 View Graph   3. 🚀 Push Now",
		"  4. 📅 View Calendar  5. ❌ Close",
		" ",
		"Press number or key to navigate...",
	}

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	-- Syntax highlighting
	vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Label", 5, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Label", 8, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Label", 12, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Label", 19, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, -1, "Label", 23, 0, -1)

	-- Key mappings for quick actions
	local keymaps = {
		["1"] = function()
			vim.api.nvim_win_close(win, true)
			vim.defer_fn(enhanced_github_contributions, 100)
		end,
		["2"] = function()
			vim.api.nvim_win_close(win, true)
			vim.fn.jobstart(
				{
					"gh",
					"api",
					"graphql",
					"-f",
					"query=" .. formatted_query,
					"--jq",
					'.data.viewer.contributionsCollection.contributionCalendar.weeks[] | .contributionDays[] | "(.date): (.contributionCount)"',
				},
				{
					on_stdout = function(_, data)
						if data and data[1] then
							vim.cmd("vsplit | terminal echo '\"" .. table.concat(data, "\\n") .. "\"' | head -20")
						end
					end,
				}
			)
		end,
		["3"] = function()
			vim.api.nvim_win_close(win, true)
			local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
			if git_root and git_root ~= "" then
				-- Call your existing push function
				intelligent_git_push(git_root, 1)
			else
				vim.notify("❌ Not in a git repository", vim.log.levels.ERROR)
			end
		end,
		["4"] = function()
			vim.api.nvim_win_close(win, true)
			vim.cmd("terminal gh dash")
		end,
		["q"] = function()
			vim.api.nvim_win_close(win, true)
		end,
		["<ESC>"] = function()
			vim.api.nvim_win_close(win, true)
		end,
		["<CR>"] = function()
			vim.api.nvim_win_close(win, true)
		end,
	}

	for key, action in pairs(keymaps) do
		vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
			callback = action,
			noremap = true,
			silent = true,
			nowait = true,
		})
	end

	-- Close with 'q' or Escape
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		callback = function()
			vim.api.nvim_win_close(win, true)
		end,
		noremap = true,
		silent = true,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "", {
		callback = function()
			vim.api.nvim_win_close(win, true)
		end,
		noremap = true,
		silent = true,
	})
end

vim.keymap.set("n", "<leader>gg", enhanced_github_contributions, {
	noremap = true,
	silent = true,
	desc = "🚀 Enhanced GitHub Contributions Dashboard",
})

--p: ╰──────────── enhanced_github_contributions ────────────╯
