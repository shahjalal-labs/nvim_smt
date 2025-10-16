vim.keymap.set({ "i", "n" }, "<A-c>", "< /> <LEFT><LEFT><LEFT><LEFT>", { noremap = true })

--w:╭──────────── Block Start ────────────╮
--p: wrap current line  with div
function WrapJsxWithDiv()
	local mode = vim.fn.mode()
	local start_line, end_line

	-- If in visual mode, use selection
	if mode == "v" or mode == "V" then
		start_line = vim.fn.line("v")
		end_line = vim.fn.line(".")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
	else
		-- Use current line
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	-- Get selected lines safely
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if not lines or #lines == 0 then
		print("❌ No lines selected or found under cursor.")
		return
	end

	-- Determine base indentation from first non-empty line
	local base_indent = ""
	for _, line in ipairs(lines) do
		if line:match("%S") then
			base_indent = line:match("^%s*")
			break
		end
	end

	-- Prepare wrapped content
	local wrapped = {}
	table.insert(wrapped, base_indent .. "<div>")
	for _, line in ipairs(lines) do
		table.insert(wrapped, base_indent .. "  " .. line)
	end
	table.insert(wrapped, base_indent .. "</div>")

	-- Replace lines in buffer
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, wrapped)
	print("✅ JSX wrapped with <div>")
end

vim.keymap.set({ "n", "v" }, "<leader>ja", WrapJsxWithDiv, { desc = "Wrap JSX tag in <div>" })
--
--t: ╰───────────── Block End ─────────────╯
--
--
--
--
--
--

--p: wrap current tag with children  under a new div
function WrapJsxTagWithDiv()
	local parser = vim.treesitter.get_parser(0, "tsx")
	if not parser then
		print("❌ Treesitter parser for TSX/JSX not found")
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	-- Get current cursor position (0-indexed)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1

	-- Get node at cursor using built-in Neovim Treesitter API
	local node = root:named_descendant_for_range(row, col, row, col)

	-- Traverse up to nearest JSX element or self-closing JSX element
	while node do
		local type = node:type()
		if type == "jsx_element" or type == "jsx_self_closing_element" then
			break
		end
		node = node:parent()
	end

	if not node then
		print("❌ No JSX tag found under cursor")
		return
	end

	-- Get node range
	local start_row, _, end_row, _ = node:range()

	-- Get lines of JSX tag
	local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
	if not lines or #lines == 0 then
		print("❌ Could not get JSX lines")
		return
	end

	-- Get indentation from first line
	local base_indent = lines[1]:match("^%s*") or ""

	-- Prepare wrapped lines
	local wrapped = {}
	table.insert(wrapped, base_indent .. "<div>")
	for _, line in ipairs(lines) do
		table.insert(wrapped, base_indent .. "  " .. line)
	end
	table.insert(wrapped, base_indent .. "</div>")

	-- Replace buffer lines
	vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, wrapped)

	print("✅ Wrapped JSX tag with <div>")
end

vim.keymap.set({ "n", "v", "i" }, "<leader>jb", WrapJsxTagWithDiv, { desc = "Wrap JSX tag with <div>" })
--
--
--
--
--
--
--
--
--

function WrapJsxTagWithCustomWrapper()
	-- Prompt for wrapper tag name
	vim.ui.input({ prompt = "Enter wrapper tag name: " }, function(input)
		if not input or input:match("^%s*$") then
			print("❌ Wrapper tag name cannot be empty")
			return
		end

		local wrapper = input

		-- Treesitter parser setup
		local parser = vim.treesitter.get_parser(0, "tsx")
		if not parser then
			print("❌ Treesitter parser for TSX/JSX not found")
			return
		end

		local tree = parser:parse()[1]
		local root = tree:root()

		-- Cursor position (0-indexed)
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		row = row - 1

		-- Get node at cursor
		local node = root:named_descendant_for_range(row, col, row, col)

		-- Find nearest JSX element or self-closing element
		while node do
			local t = node:type()
			if t == "jsx_element" or t == "jsx_self_closing_element" then
				break
			end
			node = node:parent()
		end

		if not node then
			print("❌ No JSX tag found under cursor")
			return
		end

		-- Get range of JSX node
		local start_row, _, end_row, _ = node:range()

		-- Get JSX lines
		local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
		if not lines or #lines == 0 then
			print("❌ Could not get JSX lines")
			return
		end

		-- Get base indentation from first line
		local base_indent = lines[1]:match("^%s*") or ""

		-- Prepare wrapped lines with custom wrapper
		local wrapped = {}
		table.insert(wrapped, base_indent .. "<" .. wrapper .. ">")
		for _, line in ipairs(lines) do
			table.insert(wrapped, base_indent .. "  " .. line)
		end
		table.insert(wrapped, base_indent .. "</" .. wrapper .. ">")

		-- Replace original lines with wrapped content
		vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, wrapped)

		print("✅ Wrapped JSX tag with <" .. wrapper .. ">")
	end)
end
vim.keymap.set(
	{ "n", "v", "i" },
	"<leader>jw",
	WrapJsxTagWithCustomWrapper,
	{ desc = "Wrap JSX tag with custom wrapper" }
)
----
---
---
---
---
---
---

function WrapJsxTagWithWrapperAndFocus()
	vim.ui.input({ prompt = "Enter wrapper tag name: " }, function(input)
		if not input or input:match("^%s*$") then
			print("❌ Wrapper tag name cannot be empty")
			return
		end

		local wrapper = input

		local parser = vim.treesitter.get_parser(0, "tsx")
		if not parser then
			print("❌ Treesitter parser for TSX/JSX not found")
			return
		end

		local tree = parser:parse()[1]
		local root = tree:root()

		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		row = row - 1

		local node = root:named_descendant_for_range(row, col, row, col)

		while node do
			local t = node:type()
			if t == "jsx_element" or t == "jsx_self_closing_element" then
				break
			end
			node = node:parent()
		end

		if not node then
			print("❌ No JSX tag found under cursor")
			return
		end

		local start_row, _, end_row, _ = node:range()

		local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
		if not lines or #lines == 0 then
			print("❌ Could not get JSX lines")
			return
		end

		local base_indent = lines[1]:match("^%s*") or ""

		local wrapped = {}
		table.insert(wrapped, base_indent .. "<" .. wrapper .. ">")
		for _, line in ipairs(lines) do
			table.insert(wrapped, base_indent .. "  " .. line)
		end
		table.insert(wrapped, base_indent .. "</" .. wrapper .. ">")

		vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, wrapped)

		local cursor_line = start_row + 1
		local col_position = base_indent:len() + 1 + #wrapper + 1

		vim.api.nvim_win_set_cursor(0, { cursor_line, col_position })
		vim.cmd("startinsert")

		print("✅ Wrapped JSX tag with <" .. wrapper .. "> and focused inside opening tag")
	end)
end
vim.keymap.set(
	{ "n", "v", "i" },
	"<leader>je",
	WrapJsxTagWithWrapperAndFocus,
	{ desc = "Wrap JSX tag with wrapper + focus inside" }
)

---***#*** ---- //***#***//**##**-----------
function WrapJsxTagWithDivAndClassname()
	local parser = vim.treesitter.get_parser(0, "tsx")
	if not parser then
		print("❌ Treesitter parser for TSX/JSX not found")
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1

	local node = root:named_descendant_for_range(row, col, row, col)

	while node do
		local t = node:type()
		if t == "jsx_element" or t == "jsx_self_closing_element" then
			break
		end
		node = node:parent()
	end

	if not node then
		print("❌ No JSX tag found under cursor")
		return
	end

	local start_row, _, end_row, _ = node:range()
	local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
	if not lines or #lines == 0 then
		print("❌ Could not get JSX lines")
		return
	end

	local base_indent = lines[1]:match("^%s*") or ""

	-- Prepare lines with className=""
	local wrapped = {}
	table.insert(wrapped, base_indent .. '<div className="">')
	for _, line in ipairs(lines) do
		table.insert(wrapped, base_indent .. "  " .. line)
	end
	table.insert(wrapped, base_indent .. "</div>")

	-- Replace buffer lines
	vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, wrapped)

	-- Set cursor inside the className quotes
	local cursor_row = start_row
	local cursor_col = #base_indent + string.len('<div className="') -- position inside the quotes

	vim.api.nvim_win_set_cursor(0, { cursor_row + 1, cursor_col })
	vim.cmd("startinsert")

	print('✅ Wrapped with <div className=""> and placed cursor inside')
end

vim.keymap.set(
	{ "n", "v", "i" },
	"<leader>jf",
	WrapJsxTagWithDivAndClassname,
	{ desc = 'Wrap JSX tag with <div className=""> and enter insert mode' }
)

--p: insert jsx empty fragment
function InsertJsxFragmentAtCursor()
	local mode = vim.fn.mode()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]

	-- Adjust col for insert mode (cursor is 1 char ahead in insert mode)
	if mode == "i" then
		col = col - 1
	end

	local line = vim.api.nvim_get_current_line()
	local indent = line:match("^%s*") or ""
	local before = line:sub(1, col)
	local after = line:sub(col + 1)

	-- JSX fragment with correct indentation
	local new_lines = {
		before .. "<>",
		indent .. "  ",
		indent .. "</>;" .. after,
	}

	-- Replace current line
	vim.api.nvim_buf_set_lines(0, row, row + 1, false, new_lines)

	-- Move cursor to middle line, just after indentation
	vim.api.nvim_win_set_cursor(0, { row + 2, #indent + 2 })

	-- Enter insert mode
	vim.cmd("startinsert")

	print("✅ JSX fragment inserted")
end

-- Keymap for both normal and insert mode
vim.keymap.set({ "n", "i" }, "<leader>jg", InsertJsxFragmentAtCursor, { desc = "Insert JSX fragment <></> at cursor" })



--
--
--
--
--
--
--
function WrapVisualSelectionWithDiv()
	local start_pos = vim.fn.getpos("v") -- visual start
	local end_pos = vim.fn.getpos(".") -- visual end (current cursor)

	local start_line = math.min(start_pos[2], end_pos[2]) - 1
	local end_line = math.max(start_pos[2], end_pos[2]) - 1

	-- Get selected lines
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
	if not lines or #lines == 0 then
		print("❌ No lines selected")
		return
	end

	-- Determine base indentation from first selected line
	local base_indent = lines[1]:match("^%s*") or ""

	-- Prepare wrapped lines
	local wrapped = {}
	table.insert(wrapped, base_indent .. '<div className="">')
	for _, line in ipairs(lines) do
		table.insert(wrapped, base_indent .. "  " .. line)
	end
	table.insert(wrapped, base_indent .. "</div>")

	-- Replace lines in buffer
	vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, wrapped)

	-- Set cursor inside the className quotes (on the opening div line)
	local cursor_row = start_line
	local cursor_col = #base_indent + string.len('<div className="')

	vim.api.nvim_win_set_cursor(0, { cursor_row + 1, cursor_col })

	-- Enter insert mode
	vim.cmd("startinsert")

	print('✅ Wrapped selection with <div className="">')
end

-- Map to visual mode with <leader>jv
vim.keymap.set("v", "<leader>jv", WrapVisualSelectionWithDiv, { desc = 'Wrap selection with <div className="">' })
