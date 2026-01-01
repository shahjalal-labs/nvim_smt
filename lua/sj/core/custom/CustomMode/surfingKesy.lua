-- ~/.config/nvim/lua/sj/core/custom/CustomMode/surfingKesy.lua

local M = {}

------------------------------------------------------------
-- Highlight groups (safe to define early)
------------------------------------------------------------
vim.api.nvim_set_hl(0, "SurfWordHint", {
	fg = "#000000",
	bg = "#a6e3a1",
	bold = true,
})

------------------------------------------------------------
-- Helper: yank word at position without moving cursor
------------------------------------------------------------
local function yank_word_at(pos)
	local win = vim.api.nvim_get_current_win()

	local original_cursor = vim.api.nvim_win_get_cursor(win)

	-- Flash gives 1-based row, 0-based col → fine for set_cursor
	vim.api.nvim_win_set_cursor(win, { pos[1], pos[2] })

	vim.cmd("normal! yiw")

	vim.api.nvim_win_set_cursor(win, original_cursor)
end

------------------------------------------------------------
-- SurfingKeys-style WORD copy mode (yv)
------------------------------------------------------------
function M.copy_word_by_hint()
	-- 🔑 require INSIDE function (lazy-safe)
	local flash = require("flash")

	flash.jump({
		search = {
			mode = "search",
			max_length = 0,
		},

		label = {
			uppercase = false,
			rainbow = false,
		},

		highlight = {
			matches = false,
			label = "SurfWordHint",
		},

		action = function(match)
			yank_word_at(match.pos)
		end,
	})
end

------------------------------------------------------------
-- Keymap (safe: function wrapper delays require)
------------------------------------------------------------
vim.keymap.set("n", "yv", function()
	M.copy_word_by_hint()
end, { desc = "SurfingKeys: copy word by hint" })

return M
