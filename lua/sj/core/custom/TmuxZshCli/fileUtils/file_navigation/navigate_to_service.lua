-- w: ╭──────────── Navigate to Service ────────────╮

-- Find service file in directory
local function find_service_file(directory, current_filename)
	local base_name = current_filename:match("([^%.]+)%..+$") or current_filename:gsub("%..+$", "")
	base_name = base_name:gsub("routes", ""):gsub("controller", ""):gsub("validation", "")
	base_name = base_name:gsub("^%.+", ""):gsub("%.+$", ""):gsub("^%s+", ""):gsub("%s+$", "")

	-- Try patterns in priority order
	local patterns = {
		base_name .. ".service.ts",
		base_name .. ".service.js",
		"*.service.ts",
		"*.service.js",
	}

	for _, pattern in ipairs(patterns) do
		local file_path = directory .. "/" .. pattern
		if vim.fn.filereadable(file_path) == 1 then
			return file_path
		end
	end

	-- Fallback: glob for any service file
	local files = vim.fn.glob(directory .. "/*service*.{ts,js}", false, true)
	if #files > 0 then
		return files[1]
	end

	return nil
end

-- Extract block name - cursor can be anywhere inside the block
local function extract_current_block_name()
	local current_line = vim.fn.line(".")
	local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- Search backwards for block start
	for i = current_line, 1, -1 do
		local line = buf_lines[i]
		if
			line
			and line:match(
				"//w:.*╭────────────%s+(.+)%s+────────────╮"
			)
		then
			local block_name = line:match(
				"//w:.*╭────────────%s+(.+)%s+────────────╮"
			)
			return block_name and block_name:gsub("^%s*(.-)%s*$", "%1") or nil
		end
	end

	return nil
end

-- Find block in target file with flexible matching
local function find_block_in_file(file_path, block_name)
	local lines = vim.fn.readfile(file_path)

	-- Clean the block name for matching
	local clean_block = block_name:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	-- Level 1: Exact match
	for i, line in ipairs(lines) do
		if
			line:match(
				"╭────────────%s+"
					.. vim.fn.escape(block_name, "%.%^%$%*%+%-%?%[%]%{%}%|%(%)")
					.. "%s+────────────╮"
			)
		then
			return i
		end
	end

	-- Level 2: Case-insensitive match
	for i, line in ipairs(lines) do
		if
			line:lower():match(
				"╭────────────%s+"
					.. vim.fn.escape(clean_block, "%.%^%$%*%+%-%?%[%]%{%}%|%(%)")
					.. "%s+────────────╮"
			)
		then
			return i
		end
	end

	-- Level 3: Word-based matching (handle variations like "getMyProfile" vs "getMyProfileFromDB")
	local words = {}
	for word in clean_block:gmatch("%S+") do
		table.insert(words, word)
	end

	for i, line in ipairs(lines) do
		local block_match =
			line:match("╭────────────%s+(.+)%s+────────────╮")
		if block_match then
			local line_clean = block_match:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
			local match_count = 0

			for _, word in ipairs(words) do
				if line_clean:find(word, 1, true) then
					match_count = match_count + 1
				end
			end

			-- If most words match, consider it a match
			if match_count >= math.max(1, #words - 1) then
				return i
			end
		end
	end

	return 0
end

-- Main navigation function
local function navigate_to_service()
	local current_file = vim.fn.expand("%:p")
	local current_dir = vim.fn.fnamemodify(current_file, ":h")
	local current_filename = vim.fn.expand("%:t")

	-- 1. Find service file in same directory
	local service_file = find_service_file(current_dir, current_filename)
	if not service_file then
		vim.notify("No service file found", vim.log.levels.WARN)
		return
	end

	-- 2. Extract current block name (cursor can be anywhere inside block)
	local current_block_name = extract_current_block_name()

	-- 3. Find matching block in service
	local target_line = 0
	if current_block_name then
		target_line = find_block_in_file(service_file, current_block_name)
	end

	-- 4. Navigate to service file
	vim.cmd("edit " .. vim.fn.fnameescape(service_file))

	-- 5. Jump to block if found
	if target_line > 0 then
		vim.fn.cursor(target_line, 1)
		vim.cmd("normal! zz")
		vim.notify("✓ Jumped to: " .. current_block_name, vim.log.levels.INFO)
	else
		vim.notify("✓ Opened service file", vim.log.levels.INFO)
	end
end

-- Key mapping - always navigate to service
vim.keymap.set("n", "<leader>nl", navigate_to_service, { desc = "Navigate to service file" })

-- w: ╰──────────── Navigate to Service ────────────╯
