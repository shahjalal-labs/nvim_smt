local M = {}

-- Configuration
M.config = {
	enabled = true,
	filetypes = {
		"lua",
		"python",
		"javascript",
		"typescript",
		"java",
		"cpp",
		"c",
		"rust",
		"go",
		"php",
		"ruby",
		"sh",
	},
	chars = {
		top = "─",
		bottom = "─",
		left = "│",
		right = "│",
		top_left = "┌",
		top_right = "┐",
		bottom_left = "└",
		bottom_right = "┘",
	},
	highlight_groups = {
		"BlockmanLevel1",
		"BlockmanLevel2",
		"BlockmanLevel3",
		"BlockmanLevel4",
		"BlockmanLevel5",
		"BlockmanLevel6",
	},
	debounce_ms = 50,
	max_lines = 1000,
}

-- Internal state
M.ns = vim.api.nvim_create_namespace("blockman")
M.enabled = false
M.timer = nil

-- Scope patterns for different filetypes (FIXED SYNTAX)
local scope_patterns = {
	lua = {
		{ start = "function%s+.*%s*%(", end_pattern = "^end", type = "function" },
		{ start = "if%s+.*%s+then", end_pattern = "^end", type = "if" },
		{ start = "for%s+.*%s+do", end_pattern = "^end", type = "for" },
		{ start = "while%s+.*%s+do", end_pattern = "^end", type = "while" },
	},
	python = {
		{ start = "def%s+.*%s*:", end_pattern = "^%s*$", type = "function" },
		{ start = "class%s+.*%s*:", end_pattern = "^%s*$", type = "class" },
		{ start = "if%s+.*%s*:", end_pattern = "^%s*$", type = "if" },
		{ start = "for%s+.*%s*:", end_pattern = "^%s*$", type = "for" },
		{ start = "while%s+.*%s*:", end_pattern = "^%s*$", type = "while" },
		{ start = "try%s*:", end_pattern = "^%s*$", type = "try" },
	},
	javascript = {
		{ start = "function%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "class%s+%w+%s*{", end_pattern = "^%s*}", type = "class" },
		{ start = "if%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "if" },
		{ start = "for%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "for" },
	},
	typescript = {
		{ start = "function%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "class%s+%w+%s*{", end_pattern = "^%s*}", type = "class" },
		{ start = "if%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "if" },
		{ start = "for%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "for" },
	},
	java = {
		{ start = "public%s+class%s+%w+%s*{", end_pattern = "^%s*}", type = "class" },
		{ start = "private%s+class%s+%w+%s*{", end_pattern = "^%s*}", type = "class" },
		{ start = "public%s+%w+%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "private%s+%w+%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "if%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "if" },
		{ start = "for%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "for" },
	},
	c = {
		{ start = "void%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "int%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "if%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "if" },
		{ start = "for%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "for" },
	},
	cpp = {
		{ start = "void%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "int%s+%w+%s*%(%s*[%w_,%s]*%)%s*{", end_pattern = "^%s*}", type = "function" },
		{ start = "class%s+%w+%s*{", end_pattern = "^%s*}", type = "class" },
		{ start = "if%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "if" },
		{ start = "for%s*%(%s*.*%s*%)%s*{", end_pattern = "^%s*}", type = "for" },
	},
}

-- Setup highlights
local function setup_highlights()
	vim.api.nvim_set_hl(0, "BlockmanLevel1", { fg = "#FF6B6B", bold = true })
	vim.api.nvim_set_hl(0, "BlockmanLevel2", { fg = "#4ECDC4", bold = true })
	vim.api.nvim_set_hl(0, "BlockmanLevel3", { fg = "#45B7D1", bold = true })
	vim.api.nvim_set_hl(0, "BlockmanLevel4", { fg = "#96CEB4", bold = true })
	vim.api.nvim_set_hl(0, "BlockmanLevel5", { fg = "#FFEAA7", bold = true })
	vim.api.nvim_set_hl(0, "BlockmanLevel6", { fg = "#DDA0DD", bold = true })
end

-- Debounce function
local function debounce(func, wait)
	return function(...)
		if M.timer then
			M.timer:close()
		end
		local args = { ... }
		M.timer = vim.defer_fn(function()
			func(unpack(args))
		end, wait)
	end
end

-- Clear all blocks
local function clear_blocks()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

-- Get filetype patterns
local function get_filetype_patterns(ft)
	return scope_patterns[ft] or {}
end

-- Detect scopes in current buffer
local function detect_scopes()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype

	if not vim.tbl_contains(M.config.filetypes, ft) then
		return {}
	end

	local patterns = get_filetype_patterns(ft)
	local scopes = {}
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local stack = {}

	for i, line in ipairs(lines) do
		local lnum = i - 1 -- Convert to 0-based

		-- Check for scope endings
		for j = #stack, 1, -1 do
			local scope = stack[j]
			if scope.end_pattern and line:match(scope.end_pattern) then
				scope.end_lnum = lnum
				table.insert(scopes, scope)
				table.remove(stack, j)
			end
		end

		-- Check for new scope beginnings
		for _, pattern in ipairs(patterns) do
			if line:match(pattern.start) then
				table.insert(stack, {
					start_lnum = lnum,
					end_pattern = pattern.end_pattern,
					type = pattern.type,
					level = #stack + 1,
				})
			end
		end
	end

	-- Add any remaining scopes in stack
	for _, scope in ipairs(stack) do
		scope.end_lnum = #lines - 1
		table.insert(scopes, scope)
	end

	return scopes
end

-- Draw a single block
local function draw_block(scope)
	local buf = vim.api.nvim_get_current_buf()
	local chars = M.config.chars
	local level = math.min(scope.level, #M.config.highlight_groups)
	local hl_group = M.config.highlight_groups[level]

	local start_line = scope.start_lnum
	local end_line = scope.end_lnum or (start_line + 5)

	-- Safety check
	local line_count = vim.api.nvim_buf_line_count(buf)
	if end_line >= line_count then
		end_line = line_count - 1
	end

	if start_line >= line_count then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
	if #lines == 0 then
		return
	end

	-- Find maximum line length in the scope
	local max_length = 0
	for _, line in ipairs(lines) do
		max_length = math.max(max_length, #line)
	end

	-- Add some padding
	max_length = max_length + 2

	-- Draw top border
	local top_border = chars.top_left .. string.rep(chars.top, max_length) .. chars.top_right
	vim.api.nvim_buf_set_extmark(buf, M.ns, start_line, 0, {
		virt_text = { { top_border, hl_group } },
		virt_text_pos = "overlay",
	})

	-- Draw side borders
	for i = start_line + 1, end_line - 1 do
		if i < line_count then
			local line_content = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1] or ""
			local padding = string.rep(" ", max_length - #line_content)

			local bordered_line = chars.left .. line_content .. padding .. chars.right

			vim.api.nvim_buf_set_extmark(buf, M.ns, i, 0, {
				virt_text = { { bordered_line, hl_group } },
				virt_text_pos = "overlay",
			})
		end
	end

	-- Draw bottom border
	if end_line < line_count then
		local bottom_border = chars.bottom_left .. string.rep(chars.bottom, max_length) .. chars.bottom_right
		vim.api.nvim_buf_set_extmark(buf, M.ns, end_line, 0, {
			virt_text = { { bottom_border, hl_group } },
			virt_text_pos = "overlay",
		})
	end
end

-- Main function to draw all blocks
local function draw_blocks()
	if not M.enabled then
		return
	end

	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_line_count(buf) > M.config.max_lines then
		return -- Skip for large files
	end

	clear_blocks()
	local scopes = detect_scopes()

	for _, scope in ipairs(scopes) do
		draw_block(scope)
	end
end

-- Debounced version of draw_blocks
local debounced_draw_blocks = debounce(draw_blocks, M.config.debounce_ms)

-- Enable Blockman
function M.enable()
	if M.enabled then
		return
	end

	M.enabled = true

	-- Create autocommands
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
		callback = debounced_draw_blocks,
	})

	-- Draw initial blocks
	vim.defer_fn(draw_blocks, 10)

	vim.notify("🎯 Blockman enabled")
end

-- Disable Blockman
function M.disable()
	if not M.enabled then
		return
	end

	M.enabled = false
	clear_blocks()

	vim.notify("🎯 Blockman disabled")
end

-- Toggle Blockman
function M.toggle()
	if M.enabled then
		M.disable()
	else
		M.enable()
	end
end

-- Setup function
function M.setup(user_config)
	-- Merge user config
	if user_config then
		M.config = vim.tbl_deep_extend("force", M.config, user_config)
	end

	-- Setup highlights
	setup_highlights()

	-- Create commands
	vim.api.nvim_create_user_command("BlockmanToggle", M.toggle, {})
	vim.api.nvim_create_user_command("BlockmanEnable", M.enable, {})
	vim.api.nvim_create_user_command("BlockmanDisable", M.disable, {})

	-- Enable if configured
	if M.config.enabled then
		vim.defer_fn(M.enable, 100)
	end

	print("🎯 Blockman loaded! Use :BlockmanToggle to enable/disable")
end

return M
