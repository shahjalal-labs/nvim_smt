-- w: ╭──────────── Navigate to Project Functions ────────────╮

-- Extract functions based on dynamic file type detection
local function extract_functions()
	local filename = vim.fn.expand("%:t")
	local filetype = vim.bo.filetype
	local functions = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- 1. PRISMA SCHEMA FILES - Model navigation
	if filename == "schema.prisma" or filetype == "prisma" then
		for line_num, line in ipairs(lines) do
			local model_name = line:match("^%s*model%s+(%w+)%s*{")
			if model_name then
				table.insert(functions, {
					name = model_name,
					line = line_num,
					display = "🏗️  " .. model_name .. " (line " .. line_num .. ")",
				})
			end
		end

	-- 2. ROUTES FILES - HTTP endpoints with controller names (IMPROVED)
	elseif filename:match("%.route[s]?%.ts$") or filename:match("%.route[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			-- Match router.METHOD( - get the HTTP method
			local http_method = line:match("^%s*router%.(%w+)%(")

			if http_method then
				-- Look for controller function in current and next lines
				local controller_func = nil
				local endpoint_path = nil

				-- Extract endpoint path from current line
				endpoint_path = line:match("router%." .. http_method .. "%(%s*['\"`]([^'\"]+)['\"`]")
					or line:match("['\"`](/[^'\"]+)['\"`]")

				-- Check current line for controller function
				controller_func = line:match("Controller%.(%w+)")
					or line:match("(%w+Controller)%.[%w_]+")
					or line:match("([%w]+)Controller%.[%w_]+")

				-- If not found in current line, check next 10 lines
				if not controller_func then
					for i = line_num + 1, math.min(#lines, line_num + 10) do
						local next_line = lines[i]
						controller_func = next_line:match("Controller%.(%w+)")
							or next_line:match("(%w+Controller)%.[%w_]+")
							or next_line:match("([%w]+)Controller%.[%w_]+")
						if controller_func then
							break
						end
					end
				end

				-- Create display name
				local display_name = ""
				if controller_func and endpoint_path then
					display_name = controller_func .. " - " .. http_method:upper() .. " " .. endpoint_path
				elseif controller_func then
					display_name = controller_func .. " (" .. http_method:upper() .. ")"
				elseif endpoint_path then
					display_name = http_method:upper() .. " " .. endpoint_path
				else
					display_name = http_method:upper() .. " route"
				end

				table.insert(functions, {
					name = controller_func or http_method:upper() .. "_route",
					line = line_num,
					display = "🛣️  " .. display_name .. " (line " .. line_num .. ")",
				})
			end

			-- Also match comment blocks for endpoints
			local endpoint_name = line:match("//w:.*╭────────────%s+(.+)%s+─")
				or line:match("^%s*//%s*API ENDPOINT:%s*(.+)")
				or line:match("^%s*/%*%*%s*API ENDPOINT:%s*(.+)%s*%*/")
				or line:match("^%s*//%s*GET%s+(.+)")
				or line:match("^%s*//%s*POST%s+(.+)")
				or line:match("^%s*//%s*PUT%s+(.+)")
				or line:match("^%s*//%s*DELETE%s+(.+)")
				or line:match("^%s*//%s*PATCH%s+(.+)")

			if endpoint_name then
				table.insert(functions, {
					name = endpoint_name,
					line = line_num,
					display = "🛣️  " .. endpoint_name .. " (line " .. line_num .. ")",
				})
			end
		end

	-- 3. HURL FILES - HTTP requests (IMPROVED)
	elseif filename:match("%.api%.hurl$") or filename:match("%.hurl$") then
		for line_num, line in ipairs(lines) do
			-- Match HTTP methods and endpoints (more flexible pattern)
			local http_method, endpoint = line:match("^%s*(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD)%s+([^%s]+)")

			if http_method and endpoint then
				-- Clean up endpoint (remove variables like {{baseUrl}})
				local clean_endpoint = endpoint:gsub("{{[^}]+}}", "")
				if clean_endpoint == "" then
					clean_endpoint = endpoint
				end

				local display_name = http_method:upper() .. " " .. clean_endpoint
				table.insert(functions, {
					name = display_name,
					line = line_num,
					display = "🚀 " .. display_name .. " (line " .. line_num .. ")",
				})
			end

			-- Also match comment blocks and test separators
			local test_name = line:match("//w:.*╭────────────%s+(.+)%s+─")
				or line:match("^%s*//%s*╭────────────%s+(.+)%s+─")
				or line:match("^%s*###%s*(.+)")
				or line:match("^%s*//%s*TEST:%s*(.+)")
				or line:match("^%s*//%s*Endpoint:%s*(.+)")

			if test_name then
				table.insert(functions, {
					name = test_name,
					line = line_num,
					display = "🚀 " .. test_name .. " test (line " .. line_num .. ")",
				})
			end
		end

	-- 4. SERVICE FILES - Service functions
	elseif filename:match("%.service[s]?%.ts$") or filename:match("%.service[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			local func_name = line:match("^%s*const%s+(%w+)%s*=%s*async%s*%(")
				or line:match("^%s*const%s+(%w+)%s*=%s*function")
				or line:match("^%s*export%s+const%s+(%w+)%s*=")
				or line:match("^%s*async%s+function%s+(%w+)%(")

			if func_name and not func_name:match("[Ss]ervices$") then
				table.insert(functions, {
					name = func_name,
					line = line_num,
					display = "⚙️  " .. func_name .. " (line " .. line_num .. ")",
				})
			end
		end

	-- 5. VALIDATION FILES - Schema definitions
	elseif filename:match("%.validation[s]?%.ts$") or filename:match("%.validation[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			local schema_name = line:match("^%s*const%s+(%w+[Ss]chema)%s*=")
				or line:match("^%s*export%s+const%s+(%w+[Ss]chema)%s*=")
				or line:match("^%s*const%s+(%w+)%s*=%s*z%.object")

			if schema_name then
				local clean_name = schema_name:gsub("[Ss]chema$", "")
				if not clean_name:match("[Vv]alidation$") then
					table.insert(functions, {
						name = clean_name,
						line = line_num,
						display = "📋 " .. clean_name .. " (line " .. line_num .. ")",
					})
				end
			end
		end

	-- 6. CONTROLLER FILES - Controller functions
	elseif filename:match("%.controller[s]?%.ts$") or filename:match("%.controller[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			local func_name = line:match("^%s*const%s+(%w+)%s*=%s*catchAsync")
				or line:match("^%s*export%s+const%s+(%w+)%s*=")
				or line:match("^%s*const%s+(%w+)%s*:%s*RequestHandler")
				or line:match("^%s*function%s+(%w+)%(")

			if func_name and not func_name:match("[Cc]ontrollers$") then
				table.insert(functions, {
					name = func_name,
					line = line_num,
					display = "🎮 " .. func_name .. " (line " .. line_num .. ")",
				})
			end
		end

	-- 7. CONSTANT FILES - Constants
	elseif filename:match("%.constant%.ts$") or filename:match("%.constant%.js$") then
		for line_num, line in ipairs(lines) do
			local const_name = line:match("^%s*export%s+const%s+(%w+)%s*=")
				or line:match("^%s*const%s+(%w+)%s*=%s*%[")
				or line:match("^%s*export%s+const%s+(%w+)%s*:%s*")

			if const_name and not const_name:match("^_") then
				table.insert(functions, {
					name = const_name,
					line = line_num,
					display = "🔧 " .. const_name .. " (line " .. line_num .. ")",
				})
			end
		end
	end

	return functions
end

-- Simple fuzzy matching function
local function fuzzy_match(pattern, text)
	if not pattern or pattern == "" then
		return true
	end
	pattern = pattern:lower()
	text = text:lower()

	local pattern_chars = {}
	for char in pattern:gmatch(".") do
		table.insert(pattern_chars, char)
	end

	local text_index = 1
	for _, pattern_char in ipairs(pattern_chars) do
		text_index = text:find(pattern_char, text_index, true)
		if not text_index then
			return false
		end
		text_index = text_index + 1
	end

	return true
end

-- Create picker UI
local function show_function_picker(functions)
	if #functions == 0 then
		vim.notify("No functions found in current file", vim.log.levels.WARN)
		return
	end

	local filtered_functions = functions
	local selected_index = 1
	local search_pattern = ""

	-- Create floating window
	local width = 80
	local height = 15
	local row = math.floor(((vim.o.lines - height) / 2) - 1)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	local function update_display()
		filtered_functions = {}
		for _, func in ipairs(functions) do
			if fuzzy_match(search_pattern, func.name) then
				table.insert(filtered_functions, func)
			end
		end

		local display_lines = { "🔍 Project Functions (type to filter, j/k to navigate, Enter to select)" }
		table.insert(display_lines, "Search: " .. search_pattern)
		table.insert(display_lines, "")

		for i, func in ipairs(filtered_functions) do
			local prefix = i == selected_index and "❯ " or "  "
			table.insert(display_lines, prefix .. func.display)
		end

		while #display_lines < height do
			table.insert(display_lines, "")
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)
		vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
		if #filtered_functions > 0 then
			vim.api.nvim_buf_add_highlight(buf, -1, "Visual", selected_index + 3, 0, -1)
		end
	end

	update_display()

	-- Navigation functions
	local function close_picker()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	local function move_selection(delta)
		if #filtered_functions == 0 then
			return
		end
		selected_index = selected_index + delta
		if selected_index < 1 then
			selected_index = 1
		end
		if selected_index > #filtered_functions then
			selected_index = #filtered_functions
		end
		update_display()
	end

	local function select_function()
		if #filtered_functions > 0 then
			local selected_func = filtered_functions[selected_index]
			close_picker()

			-- Navigate to the function in current file
			vim.api.nvim_win_set_cursor(0, { selected_func.line, 0 })
			vim.cmd("normal! zz")
			vim.notify("✓ Jumped to: " .. selected_func.name, vim.log.levels.INFO)
		end
	end

	-- Key mappings
	local keymaps = {
		{ "n", "<CR>", select_function, {} },
		{ "n", "<Esc>", close_picker, {} },
		{ "n", "q", close_picker, {} },
		{
			"n",
			"k",
			function()
				move_selection(-1)
			end,
			{},
		},
		{
			"n",
			"j",
			function()
				move_selection(1)
			end,
			{},
		},
		{
			"n",
			"<Up>",
			function()
				move_selection(-1)
			end,
			{},
		},
		{
			"n",
			"<Down>",
			function()
				move_selection(1)
			end,
			{},
		},
		{
			"n",
			"<C-k>",
			function()
				move_selection(-1)
			end,
			{},
		},
		{
			"n",
			"<C-j>",
			function()
				move_selection(1)
			end,
			{},
		},
		{
			"n",
			"<BS>",
			function()
				search_pattern = search_pattern:sub(1, -2)
				selected_index = 1
				update_display()
			end,
			{},
		},
	}

	-- Apply keymaps
	for _, mapping in ipairs(keymaps) do
		vim.api.nvim_buf_set_keymap(buf, mapping[1], mapping[2], "", {
			callback = mapping[3],
		})
	end

	-- Handle typing for search
	for i = 32, 126 do
		local char = string.char(i)
		vim.api.nvim_buf_set_keymap(buf, "n", char, "", {
			callback = function()
				search_pattern = search_pattern .. char
				selected_index = 1
				update_display()
			end,
		})
	end

	-- Set focus to picker
	vim.api.nvim_set_current_win(win)
end

-- Main navigation function
local function navigate_to_project_functions()
	local functions = extract_functions()
	show_function_picker(functions)
end

-- Key mapping - universal project function navigation
vim.keymap.set("n", "<leader>pf", navigate_to_project_functions, {
	desc = "Navigate to project functions in current file",
})

-- Auto-detect supported file types
local supported_files = {
	"prisma",
	"*.service.ts",
	"*.services.ts",
	"*.service.js",
	"*.services.js",
	"*.validation.ts",
	"*.validations.ts",
	"*.validation.js",
	"*.validations.js",
	"*.controller.ts",
	"*.controllers.ts",
	"*.controller.js",
	"*.controllers.js",
	"*.route.ts",
	"*.routes.ts",
	"*.route.js",
	"*.routes.js",
	"*.api.hurl",
	"*.hurl",
	"*.constant.ts",
	"*.constant.js",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = supported_files,
	callback = function()
		vim.keymap.set("n", "<leader>pf", navigate_to_project_functions, {
			buffer = true,
			desc = "Navigate to project functions",
		})
	end,
})

-- w: ╰──────────── Navigate to Project Functions ────────────╯
