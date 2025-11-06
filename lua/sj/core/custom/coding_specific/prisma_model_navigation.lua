--[[ -- w: ╭──────────── Navigate to Prisma Models ────────────╮

-- Extract all models from current Prisma file
local function extract_prisma_models()
	local models = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for line_num, line in ipairs(lines) do
		-- Match model definitions reliably
		local model_name = line:match("^%s*model%s+(%w+)%s*%{")
		if model_name then
			table.insert(models, {
				name = model_name,
				line = line_num,
				display = model_name .. " (line " .. line_num .. ")",
			})
		end
	end

	return models
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

-- Create a simple picker UI
local function show_model_picker(models)
	local filtered_models = models
	local selected_index = 1
	local search_pattern = ""

	-- Create a floating window
	local width = 60
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
		filtered_models = {}
		for _, model in ipairs(models) do
			if fuzzy_match(search_pattern, model.name) then
				table.insert(filtered_models, model)
			end
		end

		local display_lines = { "🔍 Prisma Models (type to filter, Enter to select, Esc to close)" }
		table.insert(display_lines, "Search: " .. search_pattern)
		table.insert(display_lines, "")

		for i, model in ipairs(filtered_models) do
			local prefix = i == selected_index and "❯ " or "  "
			table.insert(display_lines, prefix .. model.display)
		end

		-- Fill remaining lines
		while #display_lines < height do
			table.insert(display_lines, "")
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)

		-- Highlight selected line
		vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
		if #filtered_models > 0 then
			vim.api.nvim_buf_add_highlight(buf, -1, "Visual", selected_index + 3, 0, -1)
		end
	end

	update_display()

	-- Key mappings
	local function close_picker()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	local function select_model()
		if #filtered_models > 0 then
			local selected_model = filtered_models[selected_index]
			close_picker()

			-- Navigate to the model
			vim.api.nvim_win_set_cursor(0, { selected_model.line, 0 })
			vim.cmd("normal! zz")
			vim.notify("✓ Jumped to: " .. selected_model.name, vim.log.levels.INFO)
		end
	end

	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
		callback = select_model,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
		callback = close_picker,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		callback = close_picker,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Up>", "", {
		callback = function()
			if selected_index > 1 then
				selected_index = selected_index - 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Down>", "", {
		callback = function()
			if selected_index < #filtered_models then
				selected_index = selected_index + 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<C-k>", "", {
		callback = function()
			if selected_index > 1 then
				selected_index = selected_index - 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<C-j>", "", {
		callback = function()
			if selected_index < #filtered_models then
				selected_index = selected_index + 1
				update_display()
			end
		end,
	})

	-- Handle typing for search
	vim.api.nvim_buf_set_keymap(buf, "n", "<BS>", "", {
		callback = function()
			search_pattern = search_pattern:sub(1, -2)
			selected_index = 1
			update_display()
		end,
	})

	-- Capture all printable characters for search
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

	-- Set focus to the picker window
	vim.api.nvim_set_current_win(win)
end

-- Main navigation function
local function navigate_to_prisma_model()
	local filetype = vim.bo.filetype
	if filetype ~= "prisma" then
		vim.notify("This is not a Prisma schema file", vim.log.levels.WARN)
		return
	end

	local models = extract_prisma_models()
	if #models == 0 then
		vim.notify("No Prisma models found in current file", vim.log.levels.WARN)
		return
	end

	show_model_picker(models)
end

-- Key mapping - navigate to Prisma models
vim.keymap.set("n", "<leader>pm", navigate_to_prisma_model, { desc = "Navigate to Prisma models" })

-- Auto-set keymap for Prisma files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "prisma",
	callback = function()
		vim.keymap.set("n", "<leader>pm", navigate_to_prisma_model, {
			buffer = true,
			desc = "Navigate to Prisma models",
		})
	end,
})

-- w: ╰──────────── Navigate to Prisma Models ────────────╯

-- w: ╭──────────── Navigate to Prisma Enums ────────────╮

-- Extract all enums from current Prisma file
local function extract_prisma_enums()
	local enums = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for line_num, line in ipairs(lines) do
		-- Match enum definitions reliably
		local enum_name = line:match("^%s*enum%s+(%w+)%s*%{")
		if enum_name then
			table.insert(enums, {
				name = enum_name,
				line = line_num,
				display = enum_name .. " (line " .. line_num .. ")",
			})
		end
	end

	return enums
end

-- Simple fuzzy matching function (same as before)
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

-- Create a simple picker UI for enums
local function show_enum_picker(enums)
	local filtered_enums = enums
	local selected_index = 1
	local search_pattern = ""

	-- Create a floating window
	local width = 60
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
		filtered_enums = {}
		for _, enum in ipairs(enums) do
			if fuzzy_match(search_pattern, enum.name) then
				table.insert(filtered_enums, enum)
			end
		end

		local display_lines = { "🔍 Prisma Enums (type to filter, Enter to select, Esc to close)" }
		table.insert(display_lines, "Search: " .. search_pattern)
		table.insert(display_lines, "")

		for i, enum in ipairs(filtered_enums) do
			local prefix = i == selected_index and "❯ " or "  "
			table.insert(display_lines, prefix .. enum.display)
		end

		-- Fill remaining lines
		while #display_lines < height do
			table.insert(display_lines, "")
		end

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)

		-- Highlight selected line
		vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
		if #filtered_enums > 0 then
			vim.api.nvim_buf_add_highlight(buf, -1, "Visual", selected_index + 3, 0, -1)
		end
	end

	update_display()

	-- Key mappings
	local function close_picker()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end

	local function select_enum()
		if #filtered_enums > 0 then
			local selected_enum = filtered_enums[selected_index]
			close_picker()

			-- Navigate to the enum
			vim.api.nvim_win_set_cursor(0, { selected_enum.line, 0 })
			vim.cmd("normal! zz")
			vim.notify("✓ Jumped to: " .. selected_enum.name, vim.log.levels.INFO)
		end
	end

	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
		callback = select_enum,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
		callback = close_picker,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		callback = close_picker,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Up>", "", {
		callback = function()
			if selected_index > 1 then
				selected_index = selected_index - 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<Down>", "", {
		callback = function()
			if selected_index < #filtered_enums then
				selected_index = selected_index + 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<C-k>", "", {
		callback = function()
			if selected_index > 1 then
				selected_index = selected_index - 1
				update_display()
			end
		end,
	})

	vim.api.nvim_buf_set_keymap(buf, "n", "<C-j>", "", {
		callback = function()
			if selected_index < #filtered_enums then
				selected_index = selected_index + 1
				update_display()
			end
		end,
	})

	-- Handle typing for search
	vim.api.nvim_buf_set_keymap(buf, "n", "<BS>", "", {
		callback = function()
			search_pattern = search_pattern:sub(1, -2)
			selected_index = 1
			update_display()
		end,
	})

	-- Capture all printable characters for search
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

	-- Set focus to the picker window
	vim.api.nvim_set_current_win(win)
end

-- Main navigation function for enums
local function navigate_to_prisma_enum()
	local filetype = vim.bo.filetype
	if filetype ~= "prisma" then
		vim.notify("This is not a Prisma schema file", vim.log.levels.WARN)
		return
	end

	local enums = extract_prisma_enums()
	if #enums == 0 then
		vim.notify("No Prisma enums found in current file", vim.log.levels.WARN)
		return
	end

	show_enum_picker(enums)
end

-- Key mapping - navigate to Prisma enums
vim.keymap.set("n", "<leader>pe", navigate_to_prisma_enum, { desc = "Navigate to Prisma enums" })

-- Auto-set keymap for Prisma files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "prisma",
	callback = function()
		vim.keymap.set("n", "<leader>pe", navigate_to_prisma_enum, {
			buffer = true,
			desc = "Navigate to Prisma enums",
		})
	end,
})

-- w: ╰──────────── Navigate to Prisma Enums ────────────╯ ]]

-- w: ╭──────────── Navigate to Project Functions ────────────╮

-- Extract functions based on dynamic file type detection
local function extract_functions()
	local filename = vim.fn.expand("%:t")
	local functions = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Service files: .service or .services
	if filename:match("%.service[s]?%.ts$") or filename:match("%.service[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			-- Match service function patterns
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

	-- Validation files: .validation or .validations
	elseif filename:match("%.validation[s]?%.ts$") or filename:match("%.validation[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			local schema_name = line:match("^%s*const%s+(%w+[Ss]chema)%s*=")
				or line:match("^%s*export%s+const%s+(%w+[Ss]chema)%s*=")
				or line:match("^%s*const%s+(%w+)%s*=%s*z%.object")
				or line:match("^%s*export%s+.*%w+%s+(%w+[Ss]chema)%s*=")

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

	-- Controller files: .controller or .controllers
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

	-- Routes files: .route or .routes
	elseif filename:match("%.route[s]?%.ts$") or filename:match("%.route[s]?%.js$") then
		for line_num, line in ipairs(lines) do
			-- Match route definitions with comments
			local route_name = line:match("//w:.*╭────────────%s+(.+)%s+─")
			if route_name then
				table.insert(functions, {
					name = route_name,
					line = line_num,
					display = "🛣️  " .. route_name .. " (line " .. line_num .. ")",
				})
			end

			-- Match router.METHOD calls with endpoint names
			local http_method = line:match("^%s*router%.(%w+)%(")
			if http_method then
				-- Look for endpoint name in nearby comments
				local endpoint_name = nil

				-- Check current line for comment
				endpoint_name = line:match("//w:.*%(%w+%)╭────────────%s+(.+)%s+─")
					or line:match("//w:.*╭────────────%s+(.+)%s+─")

				-- If not found, check previous lines
				if not endpoint_name and line_num > 1 then
					for i = line_num - 1, math.max(1, line_num - 3), -1 do
						local prev_line = lines[i]
						endpoint_name = prev_line:match(
							"//w:.*%(%w+%)╭────────────%s+(.+)%s+─"
						) or prev_line:match("//w:.*╭────────────%s+(.+)%s+─")
						if endpoint_name then
							break
						end
					end
				end

				if endpoint_name then
					table.insert(functions, {
						name = endpoint_name,
						line = line_num,
						display = "🛣️  "
							.. endpoint_name
							.. " ("
							.. http_method:upper()
							.. ") (line "
							.. line_num
							.. ")",
					})
				end
			end
		end

	-- Hurl files: .hurl or .api.hurl
	elseif filename:match("%.api%.hurl$") or filename:match("%.hurl$") then
		for line_num, line in ipairs(lines) do
			-- Match hurl test case comments
			local test_name = line:match("//w:.*╭────────────%s+(.+)%s+─")
				or line:match("^%s*//%s*╭────────────%s+(.+)%s+─")
				or line:match("^%s*//%s*TEST:%s*(.+)")
				or line:match("^%s*//%s*Endpoint:%s*(.+)")

			if test_name then
				table.insert(functions, {
					name = test_name,
					line = line_num,
					display = "🚀 " .. test_name .. " test (line " .. line_num .. ")",
				})
			end

			-- Match HTTP methods in hurl files
			local http_method = line:match("^%s*(GET|POST|PUT|PATCH|DELETE|OPTIONS)%s+")
			if http_method then
				-- Look for test name in previous comments
				local test_name = nil
				for i = line_num - 1, math.max(1, line_num - 5), -1 do
					local prev_line = lines[i]
					test_name = prev_line:match("//w:.*╭────────────%s+(.+)%s+─")
						or prev_line:match("^%s*//%s*╭────────────%s+(.+)%s+─")
						or prev_line:match("^%s*//%s*TEST:%s*(.+)")
					if test_name then
						break
					end
				end

				if test_name then
					table.insert(functions, {
						name = test_name,
						line = line_num,
						display = "🚀 " .. test_name .. " (" .. http_method .. ") (line " .. line_num .. ")",
					})
				end
			end
		end

	-- Constant files: .constant
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
	local width = 70
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
