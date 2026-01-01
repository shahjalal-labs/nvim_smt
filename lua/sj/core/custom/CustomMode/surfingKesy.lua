-- Updated surfingKesy.lua
-- Fixes for line and Tree-sitter: Ensure labels show immediately for all visible matches
-- For lines: Use pattern matching non-empty lines, force labels with empty pattern trigger
-- For Tree-sitter: Add explicit label config and ensure action triggers properly

-- Custom yank word/token with hints (unchanged, as it works)
vim.keymap.set({ "n", "x", "o" }, "<leader>yw", function()
	require("flash").jump({
		pattern = "[^ \t\n\r]+", -- Match any non-whitespace sequences (better for code tokens)
		search = {
			mode = "search",
			multi_window = false, -- Focus on current window for performance
			max_length = false, -- No max length limit
			incremental = false, -- Don't update incrementally
		},
		label = {
			min_pattern_length = 0, -- Show labels even for empty/short patterns
			distance = true, -- Prioritize closer labels
			reuse = "all", -- Reuse labels intelligently
		},
		jump = {
			autojump = false, -- Don't jump automatically; wait for label input
			pos = "start",
		},
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! yiw") -- Yank inner word (adjust to 'ye' if needed for end-inclusive)
			state:restore() -- Return to original position
		end,
	})
end, { desc = "Yank word/token with hints" })

-- Custom yank line with hints (fixed: broader pattern for all line starts, force labels)
vim.keymap.set({ "n", "x", "o" }, "<leader>yl", function()
	require("flash").jump({
		pattern = "^", -- Match absolute line starts (including empty lines if needed)
		search = {
			mode = "exact", -- Use exact to avoid fuzzy, ensure all matches
			multi_window = false,
			max_length = false,
			incremental = false,
			wrap = false, -- Don't wrap to avoid duplicates
		},
		label = {
			min_pattern_length = 0, -- Force labels immediately without typing
			after = { 0, 0 }, -- Position labels at line start
			style = "overlay", -- Overlay for visibility
			reuse = "all",
		},
		highlight = { matches = true },
		jump = {
			autojump = false,
			pos = "start",
			offset = 0,
		},
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! 0y$") -- Yank from start to end of line (handles leading whitespace)
			state:restore()
		end,
	})
end, { desc = "Yank line with hints" })

-- Custom yank block/paragraph with hints (basic, uses paragraph motion)
vim.keymap.set({ "n", "x", "o" }, "<leader>yb", function()
	require("flash").jump({
		pattern = ".", -- Match any char to hint visible positions
		search = {
			mode = "search",
			multi_window = false,
			max_length = false,
			incremental = false,
		},
		label = { min_pattern_length = 0 },
		jump = { autojump = false, pos = "start" },
		action = function(match, state)
			vim.api.nvim_win_set_cursor(match.win, match.pos)
			vim.cmd("normal! yap") -- Yank around paragraph (block separated by blank lines)
			state:restore()
		end,
	})
end, { desc = "Yank block with hints" })

-- Custom yank Tree-sitter block with hints (fixed: force labels on all visible nodes)
vim.keymap.set({ "n", "x", "o" }, "<leader>yt", function()
	require("flash").treesitter_search({
		pattern = "", -- Empty pattern to match all Tree-sitter nodes
		search = {
			multi_window = false,
			incremental = false,
			max_length = false,
			mode = "exact",
		},
		label = {
			min_pattern_length = 0, -- Show labels immediately for all nodes
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
			pos = "range", -- Highlight the range of the node
			autojump = false,
		},
		action = function(match, state)
			-- Set visual selection to the match range for yank
			vim.api.nvim_win_set_cursor(match.win, match.from)
			vim.cmd("normal! v")
			vim.api.nvim_win_set_cursor(match.win, match.to)
			vim.cmd("normal! y") -- Yank the visual selection (Tree-sitter node)
			vim.cmd("normal! <Esc>") -- Exit visual
			state:restore()
		end,
	})
end, { desc = "Yank Tree-sitter block with hints" })

-- Optional: Custom highlights for differentiation
vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff00ff", bold = true }) -- Magenta labels
-- Add rainbow for visual types if desired, e.g., in yt: rainbow = { enabled = true, shade = 5 }
