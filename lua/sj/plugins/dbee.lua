return {
	"kndndrj/nvim-dbee",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("dbee").setup({
			prefix = "<leader>D",
			connections = {
				main = "postgres://postgres:sj@localhost:5432/postgre-basics", -- replace with your DB URL
			},
		})
	end,
}
