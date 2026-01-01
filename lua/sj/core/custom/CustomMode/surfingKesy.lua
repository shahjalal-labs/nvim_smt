-- Updated surfingKesy.lua
-- Fixes: Disable prompt to avoid prompt.lua error; revert mode to "search" for regex patterns like '^'; add limit=100 to prevent too many matches/errors
-- For Tree-sitter: If doing nothing, ensure Tree-sitter parser for 'prisma' is installed (e.g., via nvim-treesitter: add 'prisma' with custom repo https://github.com/victorhqc/tree-sitter-prisma)
-- Adjust yank commands as needed (e.g., 'yiw' to 'yaw' for around word)

-- Custom yank word/token with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yw", function()
	require("flash").jump({
		pattern = "[^ \t\n\r]+", -- Match any non-whitespace sequences (better for code tokens)
		search = {
			mode = "search", -- Use search for regex support
			multi_window = false, -- Focus on current window for performance
			max_length = false,
			incremental = false,
		},
		label = {
			min_pattern_length = 0, -- Show labels immediately
			distance = true,
			reuse = "all",
		},
		jump = {
			autojump = false,
			pos = "start",
		},
		prompt = { enabled = false }, -- Disable prompt to avoid set_lines error
		limit = 100, -- Limit to 100 matches to prevent overload
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! yiw") -- Yank inner word
			state:restore()
		end,
	})
end, { desc = "Yank word/token with hints" })

-- Custom yank line with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yl", function()
	require("flash").jump({
		pattern = "^", -- Match line starts (regex anchor)
		search = {
			mode = "search", -- Required for regex
			multi_window = false,
			max_length = false,
			incremental = false,
			wrap = false,
		},
		label = {
			min_pattern_length = 0,
			after = { 0, 0 }, -- Label at line start
			style = "overlay",
			reuse = "all",
		},
		highlight = { matches = true },
		jump = {
			autojump = false,
			pos = "start",
			offset = 0,
		},
		prompt = { enabled = false }, -- Disable prompt
		limit = 100, -- Limit matches
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! 0y$") -- Yank from col 0 to end
			state:restore()
		end,
	})
end, { desc = "Yank line with hints" })

-- Custom yank block/paragraph with hints (basic Vim paragraph)
vim.keymap.set({ "n", "x", "o" }, "<leader>yb", function()
	require("flash").jump({
		pattern = ".", -- Match any char for positions
		search = {
			mode = "search",
			multi_window = false,
			max_length = false,
			incremental = false,
		},
		label = { min_pattern_length = 0 },
		jump = { autojump = false, pos = "start" },
		prompt = { enabled = false },
		limit = 100,
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! yap") -- Yank around paragraph
			state:restore()
		end,
	})
end, { desc = "Yank block with hints" })

-- Custom yank Tree-sitter block with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yt", function()
	require("flash").treesitter_search({
		pattern = "", -- Empty for all nodes
		search = {
			multi_window = false,
			incremental = false,
			max_length = false,
			mode = "search", -- Try search mode
		},
		label = {
			min_pattern_length = 0,
			before = true,
			after = true,
			style = "inline",
			reuse = "all",
		},
		highlight = {
			backdrop = true,
			matches = true,
		},
		remote_op = { restore = true, motion = true },
		jump = {
			pos = "range",
			autojump = false,
		},
		prompt = { enabled = false },
		limit = 100, -- Limit nodes
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, { match.from[1], match.from[2] - 1 }) -- Adjust 1-based
			vim.cmd("normal! v")
			vim.api.nvim_win_set_cursor(match.win, { match.to[1], match.to[2] - 1 })
			vim.cmd("normal! y") -- Yank visual range
			vim.cmd("normal! \\<Esc>")
			state:restore()
		end,
	})
end, { desc = "Yank Tree-sitter block with hints" })

-- Optional: Highlights
vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff00ff", bold = true })
