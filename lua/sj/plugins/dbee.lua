return {
	"kndndrj/nvim-dbee",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	build = ":DBee install",
	config = function()
		-- Simple keymap that works
		vim.keymap.set("n", "<leader>db", "<cmd>DBee<CR>", { desc = "Open DBee" })

		-- Wait for binary to be ready
		vim.defer_fn(function()
			local binary = vim.fn.stdpath("data") .. "/dbee/bin/dbee"
			if vim.fn.executable(binary) == 1 then
				require("dbee").setup({
					sources = {
						require("dbee.sources").EnvVarsSource:new("DATABASE_URL"),
					},
				})
				vim.notify("DBee ready!", vim.log.levels.INFO)
			else
				vim.notify("DBee binary missing. Run :DBee install", vim.log.levels.WARN)
			end
		end, 1000) -- Wait 1 second
	end,
}
