return {
	"gbprod/yanky.nvim",
	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			cancel_event = "update",
			ignore_registers = { "_" },
			update_register_on_cycle = false,
		},
		system_clipboard = {
			sync_with_ring = true,
		},
	},
	config = function(_, opts)
		-- Load the configuration for yanky.nvim
		require("yanky").setup(opts)

		-- Set keymaps after setting up Yanky with the options
		vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Yanky Put After" })
		vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Yanky Put Before" })
		vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Yanky GPut After" })
		vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Yanky GPut Before" })
		vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yanky Previous Entry" })
		vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)", { desc = "Yanky Next Entry" })
	end,
	vim.api.nvim_set_keymap(
		"i",
		"<leader>yp",
		[[<Esc>:lua require("telescope").extensions.yank_history.yank_history({})<CR>]],
		{ noremap = true, silent = true }
	),
}
