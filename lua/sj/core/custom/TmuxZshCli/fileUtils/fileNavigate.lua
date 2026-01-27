-- w: ╭──────────── Block Start ────────────╮
-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- go to package.json file
vim.keymap.set("n", "<leader>np", function()
	local package_json_path = vim.fn.findfile("package.json", ".;")
	if package_json_path ~= "" then
		vim.cmd("edit " .. package_json_path)
	else
		print("No package.json file found in the current project.")
	end
end, { noremap = true, silent = true, desc = "Open package.json" })
-- w: ╰───────────── Block End ─────────────╯

--w: (start)╭──────────── go to /src/app/routes/index.ts  ────────────╮
vim.keymap.set("n", "<leader>nR", function()
	-- Try both possible extensions
	local routes_path_ts = vim.fn.getcwd() .. "/src/app/routes/index.ts"
	local routes_path_js = vim.fn.getcwd() .. "/src/app/routes/index.js"

	if vim.fn.filereadable(routes_path_ts) == 1 then
		vim.cmd("edit " .. routes_path_ts)
	elseif vim.fn.filereadable(routes_path_js) == 1 then
		vim.cmd("edit " .. routes_path_js)
	else
		print("No src/app/routes/index.ts or .js file found in the current project.")
	end
end, { noremap = true, silent = true, desc = "Open routes index file" })
--w: (end)  ╰────────────  go to /src/app/routes/index.ts ────────────╯

--
--w: ╭──────────── Block Start ────────────╮
-- Open css file for react/nextJs projects
vim.keymap.set("n", "<leader>nc", function()
	-- First: search src/index.css
	local index_css_path = vim.fn.findfile("src/index.css", ".;")
	if index_css_path ~= "" then
		vim.cmd("edit " .. index_css_path)
		print("Opened: " .. index_css_path)
		return
	end

	-- Fallback: src/app/globals.css
	local globals_css_path = vim.fn.findfile("src/app/globals.css", ".;")
	if globals_css_path ~= "" then
		vim.cmd("edit " .. globals_css_path)
		print("Opened fallback: " .. globals_css_path)
	else
		print("No src/index.css or src/app/globals.css found in the current project.")
	end
end, { noremap = true, silent = true, desc = "Open css file for react/nextJs" })
--w: ╰───────────── Block End ─────────────╯
--
--
--
-- w: ╭──────────── Block Start ────────────╮
-- go to router.jsx file for react projects
local function goToRouterJsx()
	local paths = {
		"src/router.jsx",
		"src/router/router.jsx",
		"router.jsx",
	}

	-- Try direct common paths first
	for _, path in ipairs(paths) do
		if vim.fn.filereadable(path) == 1 then
			vim.cmd("edit " .. path)
			print("Opened: " .. path)
			return
		end
	end

	-- Fallback to search via `find`
	local result = vim.fn.systemlist("find . -type f -name 'router.jsx'")
	if #result > 0 then
		vim.cmd("edit " .. result[1])
		print("Found and opened: " .. result[1])
	else
		print("router.jsx not found.")
	end
end
vim.keymap.set("n", "<leader>nn", goToRouterJsx, { desc = "Open router.jsx" })
-- w: ╰───────────── Block End ─────────────╯
--
--
--
-- w: ╭──────────── Block Start ────────────╮
-- go to main.jsx/layout.jsx/tsx/js/ts file for react/nextJs projects
local function goToMainOrLayout()
	local function open_file(path)
		vim.cmd("edit " .. path)
		print("Opened: " .. path)
	end

	-- 1️⃣ First: Check for main.jsx in current directory
	if vim.fn.filereadable("main.jsx") == 1 then
		open_file("main.jsx")
		return
	end

	-- 2️⃣ Second: Check specifically src/app/layout.{js,ts,jsx,tsx}
	local layout_variants = {
		"src/app/layout.js",
		"src/app/layout.ts",
		"src/app/layout.jsx",
		"src/app/layout.tsx",
	}
	for _, file in ipairs(layout_variants) do
		if vim.fn.filereadable(file) == 1 then
			open_file(file)
			return
		end
	end

	-- 3️⃣ Third: Fallback - search project for layout file
	local search_cmd =
		"find . -maxdepth 4 -type f \\( -name 'layout.js' -o -name 'layout.ts' -o -name 'layout.jsx' -o -name 'layout.tsx' \\)"
	local result = vim.fn.systemlist(search_cmd)
	if #result > 0 then
		open_file(result[1])
	else
		print("No main.jsx or layout file found.")
	end
end
-- Bind to <leader>nm
vim.keymap.set("n", "<leader>nm", goToMainOrLayout, { desc = "Open main.jsx" })
-- w: ╰───────────── Block End ─────────────╯

--
--
--
-- w: ╭──────────── Block Start ────────────╮
-- Lua function to open the README.md file from the project root
local function openProjectReadme()
	local util = require("lspconfig.util") -- Neovim LSP util for root detection

	-- Detect root dir using common project markers
	local root_dir = util.root_pattern("package.json", "README.md")(vim.fn.expand("%:p"))

	if root_dir then
		local readme_path = root_dir .. "/README.md"
		if vim.fn.filereadable(readme_path) == 1 then
			vim.cmd("edit " .. readme_path)
		else
			vim.notify("README.md not found in project root.", vim.log.levels.WARN)
		end
	else
		vim.notify("Project root not found.", vim.log.levels.ERROR)
	end
end

-- Optional: map it to a keybinding (like <leader>rd)
vim.keymap.set("n", "<leader>nr", openProjectReadme, { desc = "Open project root README.md" })
-- w: ╰───────────── Block End ─────────────╯
-- w: ╭──────────── Block Start ────────────╮
-- Go to .env or .env.local in the project root
vim.keymap.set("n", "<leader>ne", function()
	local candidates = { ".env", ".env.local" }

	for _, file in ipairs(candidates) do
		if vim.fn.filereadable(file) == 1 then
			vim.cmd("edit " .. file)
			print("Opened: " .. file)
			return
		end
	end

	print("No .env or .env.local found in current directory.")
end, { noremap = true, silent = true, desc = "Open .env or .env.local" })
-- w: ╰───────────── Block End ─────────────╯
-- w: ╭──────────── Block Start ────────────╮
-- From Neovim: open textNvim.md in tmux session alwaysNvim
vim.keymap.set("n", "<leader>nw", function()
	local file = "/run/media/sj/developer/web/L1B11/textNvim.md"
	local session = "alwaysNvim"

	-- Check if tmux is running
	if vim.fn.exists("$TMUX") == 0 then
		vim.notify("Not inside tmux!", vim.log.levels.ERROR)
		return
	end

	-- Build tmux command
	local cmd = string.format(
		"tmux has-session -t %s 2>/dev/null "
			.. "|| tmux new-session -ds %s 'nvim --cmd \"autocmd VimEnter * startinsert\" %s'; "
			.. "tmux switch-client -t %s",
		session,
		session,
		file,
		session
	)

	vim.fn.system(cmd)
end, { noremap = true, silent = true, desc = "Switch to alwaysNvim session with textNvim.md" })
-- w: ╰───────────── Block End ─────────────╯
-- w: ╭──────────── Block Start ────────────╮
-- Function to open your Tracker.md file
local function openTracker()
	local tracker_path = "/run/media/sj/developer/web/L1B11/career/JobDocuments/Tracker/Tracker.md"
	if vim.fn.filereadable(tracker_path) == 1 then
		vim.cmd("edit " .. tracker_path)
	else
		vim.notify("Tracker.md not found at " .. tracker_path, vim.log.levels.WARN)
	end
end

-- Map it to <leader>nt
vim.keymap.set("n", "<leader>nt", openTracker, { desc = "Open Tracker.md" })

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open src/server.ts in current working directory
local function openServer()
	local server_path = vim.fn.getcwd() .. "/src/server.ts"
	if vim.fn.filereadable(server_path) == 1 then
		vim.cmd("edit " .. server_path)
	else
		vim.notify("server.ts not found at " .. server_path, vim.log.levels.WARN)
	end
end

-- Map it to <leader>ns
vim.keymap.set("n", "<leader>ns", openServer, { desc = "Open src/server.ts" })

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open app.ts at fixed path
local function openApp()
	local cwd = vim.fn.getcwd() -- current working directory
	local app_path = cwd .. "/src/app.ts"

	if vim.fn.filereadable(app_path) == 1 then
		vim.cmd("edit " .. app_path)
	else
		vim.notify("app.ts not found at " .. app_path, vim.log.levels.WARN)
	end
end

-- Map it to <leader>na
vim.keymap.set("n", "<leader>na", openApp, { desc = "Open app.ts" })

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open prisma/schema.prisma in current working directory
local function openPrismaSchema()
	local schema_path = vim.fn.getcwd() .. "/prisma/schema.prisma"
	if vim.fn.filereadable(schema_path) == 1 then
		vim.cmd("edit " .. schema_path)
	else
		vim.notify("schema.prisma not found at " .. schema_path, vim.log.levels.WARN)
	end
end

-- Map it to <leader>ni
vim.keymap.set("n", "<leader>ni", openPrismaSchema, { desc = "Open prisma/schema.prisma" })
-- w: ╰───────────── Block End ─────────────╯
--
--
-- w: ╭──────────── Block Start ────────────╮
-- Function to open a sibling .hurl file in the same directory
local function openSiblingHurl()
	local current_file = vim.fn.expand("%:p") -- full path of current file
	local current_dir = vim.fn.fnamemodify(current_file, ":h") -- directory of current file

	-- Look for *.hurl files in the same directory
	local hurl_files = vim.fn.globpath(current_dir, "*.hurl", false, true)

	if #hurl_files > 0 then
		-- Open the first found .hurl file
		vim.cmd("edit " .. hurl_files[1])
	else
		vim.notify("No .hurl file found in " .. current_dir, vim.log.levels.WARN)
	end
end

-- Map it to <leader>nh
vim.keymap.set("n", "<leader>nh", openSiblingHurl, { desc = "Open sibling .hurl file" })
-- w: ╰───────────── Block End ─────────────╯
--
-- w: ╭──────────── Block Start ────────────╮
-- Function to open sibling controller file in same directory
--[[ local function openSiblingController()
	local current_file = vim.fn.expand("%:p") -- full path of current file
	local current_dir = vim.fn.fnamemodify(current_file, ":h") -- directory of current file

	-- Look for controller files in the same directory
	local controller_files = vim.fn.globpath(current_dir, "*.{controller,controllers}.{ts,js}", false, true)

	if #controller_files > 0 then
		-- Open the first found controller file
		vim.cmd("edit " .. controller_files[1])
	else
		vim.notify("No controller file found in " .. current_dir, vim.log.levels.WARN)
	end
end

-- Map it to <leader>nk k for controller
vim.keymap.set("n", "<leader>nk", openSiblingController, { desc = "Open sibling controller file" })
 ]]
-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Smart Sibling Controller Navigator v2 ────────────╮
-- Place this in your Neovim lua config. Maps to <leader>nk.
-- local api = vim.api
-- local fn = vim.fn
--
-- -- Levenshtein distance for fuzzy matching (small, fast)
-- local function levenshtein(s, t)
-- 	if s == t then
-- 		return 0
-- 	end
-- 	local m, n = #s, #t
-- 	if m == 0 then
-- 		return n
-- 	end
-- 	if n == 0 then
-- 		return m
-- 	end
-- 	local d = {}
-- 	for i = 0, m do
-- 		d[i] = {}
-- 		d[i][0] = i
-- 	end
-- 	for j = 0, n do
-- 		d[0][j] = j
-- 	end
-- 	for i = 1, m do
-- 		local si = s:sub(i, i)
-- 		for j = 1, n do
-- 			local cost = (si == t:sub(j, j)) and 0 or 1
-- 			d[i][j] = math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost)
-- 		end
-- 	end
-- 	return d[m][n]
-- end
--
-- -- Normalize names for comparison
-- local function normalize(name)
-- 	if not name then
-- 		return ""
-- 	end
-- 	local out = name:lower()
-- 	out = out:gsub("fromdb", ""):gsub("handler", ""):gsub("controller", "")
-- 	out = out:gsub("_", ""):gsub("%W", "") -- remove punctuation
-- 	return out
-- end
--
-- -- Read file contents (returns list of lines)
-- local function read_file_lines(path)
-- 	local ok, lines = pcall(fn.readfile, path)
-- 	if ok then
-- 		return lines
-- 	else
-- 		return {}
-- 	end
-- end
--
-- -- Collect candidate symbol names from a file using several patterns:
-- --  - your block markers: --w: .*NAME.*
-- --  - export const NAME = ...
-- --  - const NAME[:<type>] = ...
-- --  - function NAME(
-- --  - NAME = async
-- --  - NAME: RequestHandler =
-- local function collect_symbols_from_file(path)
-- 	local lines = read_file_lines(path)
-- 	local symbols = {}
-- 	for i, line in ipairs(lines) do
-- 		-- block marker (supports your various `--w:` formats)
-- 		local bm = line:match("%-%-w[:%s%w%p]*([%w_]+)%s*%p*$")
-- 		if bm then
-- 			symbols[#symbols + 1] = { name = bm, line = i, kind = "block" }
-- 		end
--
-- 		local patterns = {
-- 			"export%s+const%s+([%w_]+)",
-- 			"const%s+([%w_]+)%s*[:=]",
-- 			"function%s+([%w_]+)%s*%(",
-- 			"([%w_]+)%s*=%s*async",
-- 			"([%w_]+)%s*:%s*RequestHandler%s*=",
-- 			"([%w_]+)%s*:%s*any%s*=",
-- 			"([%w_]+)%.%w+%s*=%s*",
-- 		}
--
-- 		for _, pat in ipairs(patterns) do
-- 			local name = line:match(pat)
-- 			if name then
-- 				symbols[#symbols + 1] = { name = name, line = i, kind = "symbol" }
-- 			end
-- 		end
-- 	end
--
-- 	-- dedupe by name keeping first occurrence
-- 	local seen = {}
-- 	local uniq = {}
-- 	for _, s in ipairs(symbols) do
-- 		if s.name and not seen[s.name] then
-- 			seen[s.name] = true
-- 			uniq[#uniq + 1] = s
-- 		end
-- 	end
-- 	return uniq
-- end
--
-- -- Extract a probable symbol under/near cursor depending on file type:
-- -- tries several heuristics scanning nearby lines
-- local function extract_symbol_from_buffer()
-- 	local bufnr = api.nvim_get_current_buf()
-- 	local lnum = api.nvim_win_get_cursor(0)[1]
-- 	local start_line = math.max(1, lnum - 12)
-- 	local end_line = lnum + 12
-- 	local lines = api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
--
-- 	-- helper tries: search for patterns in given line, return first match
-- 	local function try_patterns(s)
-- 		if not s then
-- 			return nil
-- 		end
-- 		-- block marker
-- 		local bm = s:match("%-%-w[:%s%w%p]*([%w_]+)%s*%p*$")
-- 		if bm then
-- 			return bm
-- 		end
-- 		-- typical JS/TS definitions
-- 		local pats = {
-- 			"UserController%.([%w_]+)", -- routes like UserController.getMyProfile
-- 			"([%w_]+)%s*:%s*RequestHandler",
-- 			"export%s+const%s+([%w_]+)",
-- 			"const%s+([%w_]+)%s*[:=]",
-- 			"function%s+([%w_]+)%s*%(",
-- 			"([%w_]+)%s*=%s*catchAsync",
-- 			"([%w_]+)%s*=%s*async",
-- 			"router%.%w+%s*%(%s*['\"]", -- route declaration: we'll try to find handler after comma
-- 		}
-- 		for _, p in ipairs(pats) do
-- 			local m = s:match(p)
-- 			if m then
-- 				return m
-- 			end
-- 		end
-- 		return nil
-- 	end
--
-- 	-- 1. try current line first
-- 	local curline = api.nvim_get_current_line()
-- 	local sym = try_patterns(curline)
-- 	if sym then
-- 		return sym
-- 	end
--
-- 	-- 2. scan nearby lines for patterns
-- 	for i = 1, #lines do
-- 		local m = try_patterns(lines[i])
-- 		if m then
-- 			return m
-- 		end
-- 	end
--
-- 	return nil
-- end
--
-- -- Determine target file type for controller navigation
-- local function pick_target_for_current(file_path)
-- 	local lower = file_path:lower()
-- 	if lower:match("controller") then
-- 		return "service"
-- 	elseif lower:match("service") then
-- 		return "controller"
-- 	elseif lower:match("route") or lower:match("routes") then
-- 		return "controller"
-- 	elseif lower:match("validation") then
-- 		return "controller" -- validations often map to controller
-- 	else
-- 		-- fallback: prefer controller
-- 		return "controller"
-- 	end
-- end
--
-- -- Find sibling files in same dir matching a role keyword (controller/service)
-- local function find_sibling_files(dir, role_keyword)
-- 	local pat = dir .. "/*" .. role_keyword .. "*.{ts,js}"
-- 	local files = fn.glob(pat, false, true)
-- 	return files
-- end
--
-- -- Jump to best symbol in file (open then go)
-- local function open_file_and_jump(path, target_symbol)
-- 	if not path or path == "" then
-- 		vim.notify("No target file to open", vim.log.levels.WARN)
-- 		return
-- 	end
--
-- 	-- open file in current window
-- 	vim.cmd("edit " .. fn.fnameescape(path))
--
-- 	if not target_symbol or target_symbol == "" then
-- 		return
-- 	end
--
-- 	-- prefer block marker search first
-- 	local ok = vim.fn.search("--w:.*" .. target_symbol, "w")
-- 	if ok and ok > 0 then
-- 		return
-- 	end
--
-- 	-- then search for exact symbol
-- 	ok = vim.fn.search("\\V" .. target_symbol, "w")
-- 	if ok and ok > 0 then
-- 		return
-- 	end
--
-- 	-- try normalized fuzzy search by scanning file lines
-- 	local lines = read_file_lines(path)
-- 	local normalized_target = normalize(target_symbol)
-- 	local best = { score = 1e9, line = nil, name = nil }
-- 	for i, l in ipairs(lines) do
-- 		local word = l:match("([%w_]+)")
-- 		if word then
-- 			local sc = levenshtein(normalize(word), normalized_target)
-- 			if sc < best.score then
-- 				best = { score = sc, line = i, name = word }
-- 			end
-- 		end
-- 	end
-- 	if best.line then
-- 		vim.fn.cursor(best.line, 1)
-- 		vim.notify("Fuzzy jumped to '" .. (best.name or "?") .. "' (score " .. best.score .. ")", vim.log.levels.INFO)
-- 	else
-- 		vim.notify("Opened file but didn't find symbol: " .. target_symbol, vim.log.levels.WARN)
-- 	end
-- end
--
-- -- Main action for <leader>nk
-- local function openSiblingController()
-- 	local current_file = fn.expand("%:p")
-- 	if current_file == "" then
-- 		vim.notify("No file", vim.log.levels.WARN)
-- 		return
-- 	end
-- 	local current_dir = fn.fnamemodify(current_file, ":h")
-- 	local target_role = pick_target_for_current(current_file) -- 'controller' or 'service' etc.
-- 	local sibling_files = find_sibling_files(current_dir, target_role)
--
-- 	if #sibling_files == 0 then
-- 		vim.notify("No sibling " .. target_role .. " file found in " .. current_dir, vim.log.levels.WARN)
-- 		return
-- 	end
--
-- 	-- Best-effort symbol extraction from current buffer
-- 	local symbol = extract_symbol_from_buffer()
-- 	if not symbol then
-- 		-- as a fallback, try deriving from filename: e.g. user.service -> get a base like 'user'
-- 		symbol = fn.fnamemodify(current_file, ":t:r")
-- 	end
--
-- 	-- Gather all candidates across sibling files
-- 	local best_choice = { file = sibling_files[1], name = nil, score = 1e9 }
-- 	for _, f in ipairs(sibling_files) do
-- 		local candidates = collect_symbols_from_file(f)
-- 		-- if exact match present, pick immediately
-- 		for _, c in ipairs(candidates) do
-- 			if c.name and c.name == symbol then
-- 				best_choice = { file = f, name = c.name, score = -1 }
-- 				break
-- 			end
-- 		end
-- 		if best_choice.score == -1 then
-- 			break
-- 		end
--
-- 		-- otherwise fuzzy compare all
-- 		for _, c in ipairs(candidates) do
-- 			if c.name then
-- 				local sc = levenshtein(normalize(c.name), normalize(symbol))
-- 				if sc < best_choice.score then
-- 					best_choice = { file = f, name = c.name, score = sc }
-- 				end
-- 			end
-- 		end
-- 	end
--
-- 	-- If nothing collected, just open first sibling file
-- 	if not best_choice or not best_choice.file then
-- 		open_file_and_jump(sibling_files[1], symbol)
-- 		return
-- 	end
--
-- 	-- Open chosen file and jump
-- 	open_file_and_jump(best_choice.file, best_choice.name or symbol)
-- end
--
-- -- Map it to <leader>nk
-- vim.keymap.set("n", "<leader>nk", openSiblingController, { desc = "Smart jump to sibling controller" })
-- w: ╰──────────── Smart Sibling Controller Navigator v2 ────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open sibling validation file in same directory
local function openSiblingValidation()
	local current_file = vim.fn.expand("%:p") -- full path of current file
	local current_dir = vim.fn.fnamemodify(current_file, ":h") -- directory of current file

	-- Look for validation files in the same directory
	local validation_files = vim.fn.globpath(current_dir, "*.{validation,validations}.{ts,js}", false, true)

	if #validation_files > 0 then
		-- Open the first found validation file
		vim.cmd("edit " .. validation_files[1])
	else
		vim.notify("No validation file found in " .. current_dir, vim.log.levels.WARN)
	end
end

-- Map it to <leader>nv
vim.keymap.set("n", "<leader>nv", openSiblingValidation, { desc = "Open sibling validation file" })

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open sibling service/logic file in same directory
--[[ local function openSiblingService()
	local current_file = vim.fn.expand("%:p") -- full path of current file
	local current_dir = vim.fn.fnamemodify(current_file, ":h") -- directory of current file

	-- Look for service files in the same directory
	local service_files = vim.fn.globpath(current_dir, "*.{service,services}.{ts,js}", false, true)

	if #service_files > 0 then
		-- Open the first found service file
		vim.cmd("edit " .. service_files[1])
	else
		vim.notify("No service file found in " .. current_dir, vim.log.levels.WARN)
	end
end

-- Map it to <leader>nl l for logic
vim.keymap.set("n", "<leader>nl", openSiblingService, { desc = "Open sibling service file" }) ]]

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- Function to open sibling route/gateway file in same directory
--[[ local function openSiblingRoute()
	local current_file = vim.fn.expand("%:p") -- full path of current file
	local current_dir = vim.fn.fnamemodify(current_file, ":h") -- directory of current file

	-- Look for route files in the same directory
	local route_files = vim.fn.globpath(current_dir, "*.{route,routes}.{ts,js}", false, true)

	if #route_files > 0 then
		-- Open the first found route file
		vim.cmd("edit " .. route_files[1])
	else
		vim.notify("No route file found in " .. current_dir, vim.log.levels.WARN)
	end
end ]]

-- Map it to <leader>ng
-- vim.keymap.set("n", "<leader>ng", openSiblingRoute, { desc = "Open sibling route file" })

-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- w: ╰───────────── Block End ─────────────╯

-- w: ╭──────────── Block Start ────────────╮
-- w: ╰───────────── Block End ─────────────╯
