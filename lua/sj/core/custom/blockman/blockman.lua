local M = {}

-- Simple configuration
M.config = {
	enabled = true,
	filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
	debounce_ms = 100,
}

-- Internal state
M.ns = vim.api.nvim_create_namespace("blockman")
M.enabled = false
M.timer = nil

-- Setup highlights
local function setup_highlights()
	vim.api.nvim_set_hl(0, "BlockmanBorder", { fg = "#FF6B6B", bold = true })
end

-- Clear all blocks
local function clear_blocks()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

-- Simple scope detection for JS/TS
local function detect_scopes()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local scopes = {}

	local stack = {}
	local current_level = 0

	for i, line in ipairs(lines) do
		local lnum = i - 1

		-- Count opening and closing braces/brackets
		local open_braces = select(2, line:gsub("{", ""))
		local close_braces = select(2, line:gsub("}", ""))
		local open_parens = select(2, line:gsub("%(", ""))
		local close_parens = select(2, line:gsub("%)", ""))

		-- Detect function declarations
		if
			line:match("function%s+%w+%s*%(")
			or line:match("const%s+%w+%s*=%s*function")
			or line:match("const%s+%w+%s*=%s*%(")
			or line:match("class%s+%w+")
		then
			current_level = current_level + 1
			table.insert(stack, {
				start_lnum = lnum,
				level = current_level,
				type = "function",
			})
		end

		-- Detect if statements, for loops, etc.
		if line:match("if%s*%(") or line:match("for%s*%(") or line:match("while%s*%(") then
			current_level = current_level + 1
			table.insert(stack, {
				start_lnum = lnum,
				level = current_level,
				type = "block",
			})
		end

		-- Handle brace changes
		if open_braces > 0 then
			for _ = 1, open_braces do
				current_level = current_level + 1
				if #stack > 0 then
					local last_scope = stack[#stack]
					if not last_scope.brace_start then
						last_scope.brace_start = lnum
					end
				end
			end
		end

		if close_braces > 0 then
			for _ = 1, close_braces do
				if current_level > 0 then
					-- Find the most recent scope at this level
					for j = #stack, 1, -1 do
						local scope = stack[j]
						if scope.level == current_level and not scope.end_lnum then
							scope.end_lnum = lnum
							table.insert(scopes, scope)
							table.remove(stack, j)
							break
						end
					end
					current_level = current_level - 1
				end
			end
		end
	end

	return scopes
end

-- Draw a simple block
local function draw_block(scope)
	local buf = vim.api.nvim_get_current_buf()

	local start_line = scope.start_lnum
	local end_line = scope.end_lnum

	if not end_line or end_line <= start_line then
		end_line = start_line + 3 -- Default fallback
	end

	-- Get the lines in this scope
	local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
	if #lines == 0 then
		return
	end

	-- Find the maximum line length
	local max_length = 0
	for _, line in ipairs(lines) do
		max_length = math.max(max_length, #line)
	end

	-- Add some padding
	max_length = max_length + 4

	-- Draw simple borders
	local top_border = "┌" .. string.rep("─", max_length) .. "┐"
	local bottom_border = "└" .. string.rep("─", max_length) .. "┘"

	-- Top border
	vim.api.nvim_buf_set_extmark(buf, M.ns, start_line, 0, {
		virt_text = { { top_border, "BlockmanBorder" } },
		virt_text_pos = "overlay",
	})

	-- Side borders for content lines
	for i = start_line + 1, end_line do
		if i < vim.api.nvim_buf_line_count(buf) then
			local line_content = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1] or ""
			local padding = string.rep(" ", max_length - #line_content)
			local bordered_line = "│ " .. line_content .. padding .. " │"

			vim.api.nvim_buf_set_extmark(buf, M.ns, i, 0, {
				virt_text = { { bordered_line, "BlockmanBorder" } },
				virt_text_pos = "overlay",
			})
		end
	end

	-- Bottom border
	if end_line < vim.api.nvim_buf_line_count(buf) then
		vim.api.nvim_buf_set_extmark(buf, M.ns, end_line, 0, {
			virt_text = { { bottom_border, "BlockmanBorder" } },
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
	local ft = vim.bo[buf].filetype

	if not vim.tbl_contains(M.config.filetypes, ft) then
		return
	end

	clear_blocks()
	local scopes = detect_scopes()

	for _, scope in ipairs(scopes) do
		draw_block(scope)
	end
end

-- Debounced drawing
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

local debounced_draw_blocks = debounce(draw_blocks, M.config.debounce_ms)

-- Enable Blockman
function M.enable()
	if M.enabled then
		return
	end

	M.enabled = true
	setup_highlights()

	-- Create autocommands
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
		callback = debounced_draw_blocks,
	})

	-- Draw initial blocks
	vim.defer_fn(draw_blocks, 50)

	print("🎯 Blockman enabled for JS/TS/JSX/TSX")
end

-- Disable Blockman
function M.disable()
	if not M.enabled then
		return
	end

	M.enabled = false
	clear_blocks()

	print("🎯 Blockman disabled")
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
	if user_config then
		M.config = vim.tbl_deep_extend("force", M.config, user_config)
	end

	-- Enable if configured
	if M.config.enabled then
		vim.defer_fn(M.enable, 100)
	end

	-- Create commands
	vim.api.nvim_create_user_command("BlockmanToggle", M.toggle, {})
	vim.api.nvim_create_user_command("BlockmanEnable", M.enable, {})
	vim.api.nvim_create_user_command("BlockmanDisable", M.disable, {})

	print("🎯 Simple Blockman loaded! Use :BlockmanToggle")
end

return M
