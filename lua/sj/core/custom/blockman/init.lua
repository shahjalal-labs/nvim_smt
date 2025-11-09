require("sj.core.custom.blockman.blockman")
-- Load and setup Blockman
local blockman = require("sj.core.custom.blockman.blockman")

blockman.setup({
	enabled = true,
	filetypes = { "lua", "python", "javascript", "typescript" },

	-- Optional: Custom characters
	chars = {
		top = "═",
		bottom = "═",
		left = "║",
		right = "║",
		top_left = "╔",
		top_right = "╗",
		bottom_left = "╚",
		bottom_right = "╝",
	},
})

-- Keymaps for easy access
vim.keymap.set("n", "<leader>vb", "<cmd>BlockmanToggle<cr>", { desc = "Toggle Blockman" })
vim.keymap.set("n", "<leader>ve", "<cmd>BlockmanEnable<cr>", { desc = "Enable Blockman" })
vim.keymap.set("n", "<leader>vd", "<cmd>BlockmanDisable<cr>", { desc = "Disable Blockman" })
