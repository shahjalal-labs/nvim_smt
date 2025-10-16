-- w: ╭──────────── Block Start ────────────╮
--t: Function to send build and cp command to tmux pane
--
--[[ function SendBuildCommandToTmuxPane()
	vim.ui.input({ prompt = "Enter tmux pane number (default 2): " }, function(input)
		-- If input is empty or nil, default to "2"
		local pane = (input == nil or input == "") and "2" or input

		local cmd = "bun run build && cp dist/index.html dist/200.html && surge ./dist"
		local tmux_cmd = string.format("tmux send-keys -t %s '%s' Enter", pane, cmd)

		vim.fn.system(tmux_cmd)
		print("Command sent to tmux pane " .. pane)
	end)
end

vim.api.nvim_set_keymap("n", "<leader>bb", ":lua SendBuildCommandToTmuxPane()<CR>", { noremap = true, silent = true }) ]]

-- send build command based on react/next project
-- ╭──────────── Block Start ────────────╮
-- Function to detect project type and send appropriate build/deploy command to tmux
function SendBuildCommandToTmuxPane()
	-- Ask user for tmux pane number
	vim.ui.input({ prompt = "Enter tmux pane number (default 2): " }, function(input)
		local pane = (input == nil or input == "") and "2" or input

		-- Read package.json
		local package_json_path = vim.fn.getcwd() .. "/package.json"
		local cmd

		if vim.fn.filereadable(package_json_path) == 1 then
			local content = vim.fn.readfile(package_json_path)
			local package_str = table.concat(content, "\n")

			local is_next = package_str:match('"next"%s*:')
			local is_react = package_str:match('"react"%s*:')

			if is_next then
				cmd = "bunx vercel --prod"
			elseif is_react then
				cmd = "bun run build && cp dist/index.html dist/200.html && surge ./dist"
			else
				print("⚠️ Unknown project type, defaulting to React build...")
				cmd = "bun run build && cp dist/index.html dist/200.html && surge ./dist"
			end
		else
			print("⚠️ No package.json found, defaulting to React build...")
			cmd = "bun run build && cp dist/index.html dist/200.html && surge ./dist"
		end

		-- Send command to tmux
		local tmux_cmd = string.format("tmux send-keys -t %s '%s' Enter", pane, cmd)
		vim.fn.system(tmux_cmd)
		print("🚀 Command sent to tmux pane " .. pane .. ": " .. cmd)
	end)
end

-- Map key
vim.api.nvim_set_keymap("n", "<leader>bb", ":lua SendBuildCommandToTmuxPane()<CR>", { noremap = true, silent = true })
-- ╰───────────── Block End ─────────────╯

-- w: ╰───────────── Block End ─────────────╯

--p: ╭──────────── Block Start ────────────╮
--w: open url in browser from CNAME
local function open_cname_url_direct()
	local cwd = vim.fn.getcwd()
	local filepath = cwd .. "/public/CNAME"

	local file = io.open(filepath, "r")
	if not file then
		vim.notify("❌ CNAME file not found in " .. filepath, vim.log.levels.ERROR)
		return
	end

	local url = file:read("*l")
	file:close()

	if not url or url == "" then
		vim.notify("❌ URL not found in CNAME file.", vim.log.levels.ERROR)
		return
	end

	-- Prepend https:// if missing
	if not url:match("^https?://") then
		url = "https://" .. url
	end

	local open_cmd = string.format("xdg-open '%s' >/dev/null 2>&1 &", url)
	os.execute(open_cmd)

	vim.notify("🌐 Opening in browser: " .. url, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>bc", open_cname_url_direct, {
	noremap = true,
	silent = true,
	desc = "Directly open CNAME URL in browser",
})
--p: ╰───────────── Block End ─────────────╯
--
--p: ╭──────────── Block Start ────────────╮
--w: build, cp and browser open the buld project
local function BuildCopyOpenInTmux()
	local cwd = vim.fn.getcwd()
	local cname_path = cwd .. "/public/CNAME"

	local file = io.open(cname_path, "r")
	if not file then
		vim.notify("❌ CNAME file not found in " .. cname_path, vim.log.levels.ERROR)
		return
	end

	local url = file:read("*l")
	file:close()

	if not url or url == "" then
		vim.notify("❌ CNAME file is empty.", vim.log.levels.ERROR)
		return
	end

	if not url:match("^https?://") then
		url = "https://" .. url
	end

	local build_cmd =
		string.format("bun run build && cp dist/index.html dist/200.html &&  surge ./dist  && xdg-open '%s'", url)
	local user_input = nil
	local done = false

	-- Fallback if no input is given within 1000ms
	vim.defer_fn(function()
		if not done then
			local fallback_pane = "2"
			local tmux_cmd = string.format('tmux send-keys -t %s "%s" Enter', fallback_pane, build_cmd)
			os.execute(tmux_cmd)
			vim.notify("🕒 Timeout: Sent to tmux pane 2 by default.", vim.log.levels.WARN)
			done = true
		end
	end, 1000)

	-- Prompt for pane input
	vim.schedule(function()
		user_input = vim.fn.input("📦 Enter tmux pane number (default: 2): ")
		if not done then
			local pane = (user_input ~= "" and user_input) or "2"
			local tmux_cmd = string.format('tmux send-keys -t %s "%s" Enter', pane, build_cmd)
			os.execute(tmux_cmd)
			vim.notify("🚀 Sent to tmux pane " .. pane .. ": Build + Open", vim.log.levels.INFO)
			done = true
		end
	end)
end

vim.keymap.set("n", "<leader>bo", BuildCopyOpenInTmux, {
	noremap = true,
	silent = true,
	desc = "Build + copy + open in tmux pane",
})
--p: ╰───────────── Block End ─────────────╯
--
--
--
--p: ╭──────────── Block Start ────────────╮
vim.keymap.set("n", "<leader>bj", function()
	local cwd = vim.fn.getcwd()
	local cmd = string.format("cd %s && npx vite --open", cwd)
	local tmux_cmd = string.format([[tmux send-keys -t 3 "%s" C-m]], cmd)
	os.execute(tmux_cmd)
end, { desc = "Start Vite in tmux pane 3 with browser", silent = true })
--p: ╰───────────── Block End ─────────────╯
--
