vim.filetype.add({
	extension = {
		["http"] = "http",
	},
})

return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		global_keymaps = false,
	},
	config = function()
		vim.keymap.set("n", "<leader>Rs", "<cmd>KulalaSend<CR>", { desc = "Send request" })
		vim.keymap.set("n", "<leader>Ra", "<cmd>KulalaSendAll<CR>", { desc = "Send all requests" })
		vim.keymap.set("n", "<leader>Rb", "<cmd>KulalaScratchpad<CR>", { desc = "Kulala scratchpad" })
		vim.keymap.set("n", "<leader>Re", "<cmd>KulalaSelectEnv<CR>", { desc = "Select Kulala env" })
	end,
}
