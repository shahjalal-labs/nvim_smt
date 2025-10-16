local last_component_file = nil
local last_cursor_pos = nil

-- Safely write before editing another file
local function safe_edit(file)
	if vim.bo.modified then
		vim.cmd("write")
	end
	vim.cmd("edit " .. file)
end

local function auto_paste_to_component()
	local clipboard = vim.fn.getreg("+")
	if clipboard == nil or clipboard == "" then
		vim.notify("📋 Clipboard is empty!", vim.log.levels.WARN)
		return false
	end

	local component_pattern = "const%s+(%w+)%s*=%s*%(%s*%)%s*=>%s*{"
	local recent_files = vim.v.oldfiles
	local max_files = math.min(3, #recent_files)

	for i = 1, max_files do
		local file = recent_files[i]
		if file:match("%.jsx$") or file:match("%.tsx$") then
			local lines = vim.fn.readfile(file)
			local content = table.concat(lines, "\n")
			local component_name = content:match(component_pattern)

			if component_name then
				safe_edit(file)

				-- Case 1: Single-line return <div></div>;
				for lnum, line in ipairs(lines) do
					if line:match("^%s*return%s*<div>%s*</div>%s*;") then
						local indent = line:match("^(%s*)return") or ""
						local new_lines = {
							indent .. "return (",
							indent .. "  <div>",
						}
						for clip_line in clipboard:gmatch("[^\r\n]+") do
							table.insert(new_lines, indent .. "    " .. clip_line)
						end
						table.insert(new_lines, indent .. "  </div>")
						table.insert(new_lines, indent .. ");")

						vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, new_lines)
						vim.api.nvim_win_set_cursor(0, { lnum + 2, 0 })
						vim.cmd("write")
						last_component_file = file
						last_cursor_pos = { lnum + 2, 0 }
						return true
					end
				end

				-- Case 2: Multiline return
				for lnum = 1, #lines - 4 do
					if
						lines[lnum]:match("^%s*return%s*%(%s*$")
						and lines[lnum + 1]:match("^%s*<div>%s*$")
						and lines[lnum + 3]:match("^%s*</div>%s*$")
						and lines[lnum + 4]:match("^%s*%)%s*;?%s*$")
					then
						local indent = lines[lnum + 1]:match("^(%s*)<div>") or ""
						local clip_lines = {}
						for clip_line in clipboard:gmatch("[^\r\n]+") do
							table.insert(clip_lines, indent .. "  " .. clip_line)
						end

						vim.api.nvim_buf_set_lines(0, lnum + 1, lnum + 1, false, clip_lines)
						vim.api.nvim_win_set_cursor(0, { lnum + 2, 0 })
						vim.cmd("write")
						last_component_file = file
						last_cursor_pos = { lnum + 2, 0 }
						return true
					end
				end
			end
		end
	end

	vim.notify("❌ No valid empty component found.", vim.log.levels.WARN)
	return false
end

local function visual_cut_and_paste()
	-- Step 1: cut selection into clipboard
	vim.cmd('normal! "+d')

	-- Step 2: paste into valid component
	vim.defer_fn(function()
		local success = auto_paste_to_component()
		if success and last_component_file and last_cursor_pos then
			vim.defer_fn(function()
				safe_edit(last_component_file)
				vim.api.nvim_win_set_cursor(0, last_cursor_pos)
				vim.notify("✅ JSX moved and focus switched", vim.log.levels.INFO)
			end, 300)
		end
	end, 300)
end

-- Visual mode only: cut + paste to component
vim.keymap.set("v", "<leader>cp", visual_cut_and_paste, {
	desc = "Cut JSX and move it to the last created component",
	noremap = true,
	silent = true,
})

-- jump_to_jsx_parent_dynamic.lua
-- 🔍 Dynamically search JSX/TSX parent component usage (not props/imports)
-- 🚀 Matches all valid forms like:
--     <Component />
--     <Component prop="x" />
--     <Component></Component>

-- Safe edit helper: saves if modified then edits file

-- Jump to JSX Parent component
local function jump_to_jsx_parent()
	-- Get current filename without extension (component name)
	local filename = vim.fn.expand("%:t:r")
	-- Build pattern just "<ComponentName" for flexible JSX tag matching
	local pattern = "<" .. filename

	-- Use Telescope grep_string with regex inside src/ directory, prefill prompt with pattern
	require("telescope.builtin").grep_string({
		search = pattern,
		prompt_title = "🔍 JSX Usage of <" .. filename,
		use_regex = true,
		cwd = "src",
		default_text = pattern, -- Prefill input so you can refine search
	})
end

-- to jump_to_jsx_parent take current from cursor existing word
vim.keymap.set("n", "<leader>jh", jump_to_jsx_parent, { desc = "Jump to JSX Parent (Usage Search)" })

local function jump_to_jsx_parent_from_cursor()
	local word = vim.fn.expand("<cword>")
	if word == "" then
		print("No word under cursor")
		return
	end

	-- Pattern just "<Child" so it matches opening tag start flexibly
	local pattern = "<" .. word

	require("telescope.builtin").grep_string({
		search = pattern,
		prompt_title = "🔍 JSX Usage of <" .. word,
		use_regex = true,
		cwd = "src",
		default_text = pattern, -- Pre-fill prompt with <Child so you can refine
	})
end

vim.keymap.set("n", "<leader>jm", jump_to_jsx_parent_from_cursor, { desc = "Jump to JSX Parent from Cursor Word" })
