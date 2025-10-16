local uv = vim.loop

local function run_cmd(cmd, args, cwd)
	local stdout = {}
	local stderr = {}
	local done = false
	local exit_code = nil

	local stdout_pipe = uv.new_pipe(false)
	local stderr_pipe = uv.new_pipe(false)
	local handle

	local function on_exit(code, _)
		exit_code = code
		done = true
	end

	handle = uv.spawn(cmd, {
		args = args,
		cwd = cwd,
		stdio = { nil, stdout_pipe, stderr_pipe },
	}, on_exit)

	if not handle then
		return false, "Failed to spawn process"
	end

	stdout_pipe:read_start(function(err, data)
		if err then
			done = true
			return
		end
		if data then
			table.insert(stdout, data)
		else
			stdout_pipe:read_stop()
		end
	end)

	stderr_pipe:read_start(function(err, data)
		if err then
			done = true
			return
		end
		if data then
			table.insert(stderr, data)
		else
			stderr_pipe:read_stop()
		end
	end)

	local timer = uv.new_timer()
	timer:start(3000, 0, function()
		if not done and handle then
			handle:kill()
			done = true
		end
		timer:stop()
		timer:close()
	end)

	while not done do
		vim.wait(10)
	end

	if stdout_pipe and not stdout_pipe:is_closing() then
		stdout_pipe:close()
	end
	if stderr_pipe and not stderr_pipe:is_closing() then
		stderr_pipe:close()
	end
	if handle and not handle:is_closing() then
		handle:close()
	end

	if exit_code == 0 then
		return true, table.concat(stdout)
	else
		return false, table.concat(stderr)
	end
end

local function get_git_remote_url()
	local cwd = vim.fn.getcwd()
	local ok, out = run_cmd("git", { "config", "--get", "remote.origin.url" }, cwd)
	if ok and out and out ~= "" then
		return vim.trim(out)
	end
	return nil, "Failed to get git remote origin URL"
end

local function parse_repo_fullname(remote_url)
	if type(remote_url) ~= "string" then
		return nil
	end
	local repo = remote_url:gsub("%.git$", ""):match("github.com[:/](.+)")
	return repo
end

local function extract_repo_intro()
	local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
	local repo_name = nil
	local intro_lines = {}
	for _, line in ipairs(lines) do
		if not repo_name and type(line) == "string" and line:match("^#%s*(.+)") then
			repo_name = line:gsub("^#%s*", "")
		elseif type(line) == "string" and line:match("^##+%s*") then
			break
		elseif type(line) == "string" and line ~= "" then
			table.insert(intro_lines, line)
		elseif #intro_lines > 0 then
			break
		end
	end
	local intro = table.concat(intro_lines, " ")
	return repo_name or "repo-name", intro
end

local function build_ghabout_content(repo_fullname, description, homepage, topics)
	local lines = {
		"## 🚀 Intro",
		string.format("Repository: %s", repo_fullname or ""),
		"",
		"```bash",
		string.format(
			"gh repo edit %s --description %q --homepage %q",
			repo_fullname or "",
			description or "",
			homepage or ""
		),
	}
	if topics and type(topics) == "table" then
		for _, topic in ipairs(topics) do
			table.insert(lines, string.format("gh repo edit %s --add-topic %s", repo_fullname or "", topic))
		end
	end
	table.insert(lines, "```")
	return table.concat(lines, "\n")
end

local function write_file(filepath, content)
	local fd, err = io.open(filepath, "w")
	if not fd then
		vim.notify("Failed to open file for writing: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return false
	end
	fd:write(content)
	fd:close()
	return true
end

local function append_file(filepath, content)
	local fd, err = io.open(filepath, "a")
	if not fd then
		vim.notify("Failed to open file for appending: " .. (err or "unknown error"), vim.log.levels.ERROR)
		return false
	end
	fd:write(content)
	fd:close()
	return true
end

local function generate_ghabout()
	vim.notify("Starting GitHub About update...", vim.log.levels.INFO)

	local remote_url, err = get_git_remote_url()
	if not remote_url then
		vim.notify("Error: " .. (err or "unknown"), vim.log.levels.ERROR)
		local file = vim.fn.getcwd() .. "/ghAbout.md"
		write_file(file, "# ERROR: Unable to fetch remote URL\nError: " .. (err or "unknown") .. "\n")
		vim.cmd("edit " .. file)
		return
	end

	local repo_fullname = parse_repo_fullname(remote_url)
	if not repo_fullname then
		vim.notify("Error: Could not parse repository fullname from URL", vim.log.levels.ERROR)
		local file = vim.fn.getcwd() .. "/ghAbout.md"
		write_file(file, "# ERROR: Could not parse repository fullname\nRemote URL: " .. remote_url .. "\n")
		vim.cmd("edit " .. file)
		return
	end

	local repo_name, intro = extract_repo_intro()
	intro = intro ~= "" and intro or "A neat repository"
	intro = intro:gsub('"', '\\"') -- escape quotes for shell

	local homepage = "http://your-homepage.example.com"
	local topics = { "portfolio", "react", "tailwind", "vite" }

	local content = build_ghabout_content(repo_fullname, intro, homepage, topics)
	local file = vim.fn.getcwd() .. "/ghAbout.md"

	if not write_file(file, content) then
		return
	end

	vim.fn.setreg("+", content)
	vim.cmd("edit " .. file)

	local cmd_desc = string.format('gh repo edit %s --description "%s" --homepage "%s"', repo_fullname, intro, homepage)
	local ok, out = run_cmd("sh", { "-c", cmd_desc }, vim.fn.getcwd())
	if not ok then
		vim.notify("Failed to update description/homepage. See ghAbout.md for details.", vim.log.levels.ERROR)
		append_file(file, "\n\n# ERROR LOGS\n$ " .. cmd_desc .. "\n" .. out .. "\n")
		return
	end

	for _, topic in ipairs(topics) do
		local cmd_topic = string.format("gh repo edit %s --add-topic %s", repo_fullname, topic)
		local ok2, out2 = run_cmd("sh", { "-c", cmd_topic }, vim.fn.getcwd())
		if not ok2 then
			vim.notify("Failed to add topic: " .. topic .. ". See ghAbout.md for details.", vim.log.levels.ERROR)
			append_file(file, "\n\n# ERROR LOGS\n$ " .. cmd_topic .. "\n" .. out2 .. "\n")
			return
		end
	end

	vim.notify("GitHub About section updated successfully!", vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>gd", generate_ghabout, { noremap = true, silent = true })
