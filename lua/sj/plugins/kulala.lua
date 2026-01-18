return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	keys = {
		{ "<leader>xr", desc = "Kulala: run request" },
		{ "<leader>xa", desc = "Kulala: run all" },
		{ "<leader>xe", desc = "Kulala: select env" },
		{ "<leader>xo", desc = "Kulala: open scratchpad" },
	},
	config = function()
		require("kulala").setup({
			global_keymaps = true,
			global_keymaps_prefix = "<leader>R",
			kulala_keymaps_prefix = "",
		})

		-- SAFE keymaps (after setup)
		vim.keymap.set("n", "<leader>rr", function()
			require("kulala").run()
		end, { desc = "Kulala: run request" })

		vim.keymap.set("n", "<leader>ra", function()
			require("kulala").run_all()
		end, { desc = "Kulala: run all" })

		vim.keymap.set("n", "<leader>re", function()
			require("kulala").select_env()
		end, { desc = "Kulala: select env" })

		vim.keymap.set("n", "<leader>ro", function()
			require("kulala").open()
		end, { desc = "Kulala: open scratchpad" })
	end,
}
