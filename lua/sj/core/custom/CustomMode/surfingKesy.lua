-- ~/.config/nvim/lua/sj/core/custom/CustomMode/surfingKesy.lua

local M = {}

local flash = require("flash")

------------------------------------------------------------
-- Highlight groups (edit colors freely)
------------------------------------------------------------
vim.api.nvim_set_hl(0, "SurfWordHint", {
	fg = "#000000",
	bg = "#a6e3a1",
	bold = true,
})

------------------------------------------------------------
-- Internal helper: yank word at position without moving cursor
------------------------------------------------------------
local function yank_word_at(pos)
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	-- save cursor
	local original_cursor = vim.api.nvim_win_get_cursor(win)

	-- move cursor to hinted word
	vim.api.nvim_win_set_cursor(win, { pos[1], pos[2] })

	-- yank inner word
	vim.cmd("normal! yiw")

	-- restore cursor
	vim.api.nvim_win_set_cursor(win, original_cursor)
end

------------------------------------------------------------
-- Public: SurfingKeys-style word copy mode
------------------------------------------------------------
function M.copy_word_by_hint()
	flash.jump({
		search = {
			mode = "search",
			-- empty pattern = Flash auto word detection
			max_length = 0,
		},

		label = {
			rainbow = false,
			uppercase = false,
		},

		highlight = {
			matches = false,
			label = "SurfWordHint",
		},

		action = function(match, _)
			yank_word_at(match.pos)
		end,
	})
end

------------------------------------------------------------
-- OPTIONAL: default keymap (change or remove later)
------------------------------------------------------------
vim.keymap.set("n", "yv", M.copy_word_by_hint, { desc = "SurfingKeys: copy word by hint" })

return M
