-- Using lazy.nvim
return {
	"sindrets/winshift.nvim",
	config = function()
		require("winshift").setup({
			highlight_moving_win = true,
			focused_hl_group = "Visual",
			moving_hl_group = "Visual",
		})
	end,
}

-- Then use:
-- <Leader>ws : Start window shift mode
-- hjkl to move window
-- Enter to confirm, ESC to cancel
