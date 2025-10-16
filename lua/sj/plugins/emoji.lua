return {
	"allaman/emoji.nvim",
	version = "1.0.0", -- Optionally pin to a specific version
	dependencies = {
		"nvim-lua/plenary.nvim", -- Required for handling paths
		"hrsh7th/nvim-cmp", -- Optional for cmp integration
		"nvim-telescope/telescope.nvim", -- Optional for Telescope integration
		"ibhagwan/fzf-lua", -- Optional for fzf-lua integration via vim.ui.select
	},
	opts = {
		enable_cmp_integration = true, -- Enable nvim-cmp integration
		plugin_path = vim.fn.stdpath("data") .. "/lazy/", -- Adjust if needed
	},
	config = function(_, opts)
		require("emoji").setup(opts)
		-- Optional: Setup Telescope keybinding for emoji search
		local ts = require("telescope").load_extension("emoji")
		vim.keymap.set({ "n", "i" }, "<leader>ii", ts.emoji, { desc = "[S]earch [E]moji" })
	end,
}
