return {
	"kndndrj/nvim-dbee",
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	config = function()
		local dbee = require("dbee")

		dbee.setup({
			prefix = "<leader>AD", -- your leader + D
			default_connection = "main",
			connections = {
				main = os.getenv("DATABASE_URL"), -- make sure DATABASE_URL is set
			},
		})

		-- optional: Telescope integration
		pcall(function()
			require("telescope").load_extension("dbee")
		end)
	end,
}
