return {
	"sindrets/winshift.nvim",
	config = function()
		require("winshift").setup({
			highlight_moving_win = true,
			focused_hl_group = "Visual",
			moving_hl_group = "Visual",
		})

		-- Custom keymaps - use <Leader>wj to start window shifting
		vim.keymap.set("n", "<Leader>wj", ":WinShift<CR>", { desc = "Start window shift mode" })
		-- Direct swap commands (no interactive mode)
		vim.keymap.set("n", "<Leader>pu", "<cmd>WinShift left<CR>")
		vim.keymap.set("n", "<Leader>pi", "<cmd>WinShift right<CR>")
		vim.keymap.set("n", "<Leader>pk", "<cmd>WinShift up<CR>")
		vim.keymap.set("n", "<Leader>pj", "<cmd>WinShift down<CR>")
		vim.keymap.set("n", "<Leader>ps", "<cmd>WinShift swap<CR>")
		-- Optional: Disable default <Leader>ws if you want only <Leader>wj
		-- vim.keymap.del("n", "<Leader>ws")
	end,
}
