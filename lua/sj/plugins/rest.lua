-- For lazy.nvim
return {
	"rest-nvim/rest.nvim",
	ft = "http",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("rest-nvim").setup({
			-- Optional: configure rest.nvim settings here
			result = {
				show_url = true,
				show_http_info = true,
				show_headers = true,
			},
		})
	end,
}
