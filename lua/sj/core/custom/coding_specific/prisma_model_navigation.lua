-- w: ╭──────────── Navigate to Prisma Models ────────────╮

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
