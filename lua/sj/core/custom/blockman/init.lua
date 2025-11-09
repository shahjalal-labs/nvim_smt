local blockman = require("sj.core.custom.blockman.blockman")

blockman.setup({
	enabled = true,
})

-- Keymaps
vim.keymap.set("n", "<leader>vb", "<cmd>BlockmanToggle<cr>", { desc = "Toggle Blockman" })
