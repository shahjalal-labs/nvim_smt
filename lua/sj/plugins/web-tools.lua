-- Place this in your lazy plugin configuration (usually in lua/plugins/web-tools.lua)
return {
	{
		"ray-x/web-tools.nvim",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
		},
		opts = {
			keymaps = {
				rename = nil, -- by default use same setup of lspconfig
				repeat_rename = ".",
			},
		},
		keys = {
			{
				"<leader>ll",
				function()
					vim.cmd("BrowserPreview") -- Open current file in browser
				end,
				desc = "Preview HTML in browser",
			},
			{
				"<leader>ls",
				function()
					vim.cmd("BrowserSync") -- Start browser-sync server
				end,
				desc = "Start browser-sync server",
			},
			{
				"<leader>lr",
				function()
					vim.cmd("BrowserRestart") -- Restart browser-sync server
				end,
				desc = "Restart browser-sync server",
			},
			{
				"<leader>lx",
				function()
					vim.cmd("BrowserStop") -- Stop browser-sync server
				end,
				desc = "Stop browser-sync server",
			},
		},
		config = function()
			-- Basic setup
			require("web-tools").setup({})

			-- Set up autocommand for HTML files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "html", "htm", "sh" },
				callback = function()
					-- You can add specific settings for HTML files here
					vim.opt_local.expandtab = true
					vim.opt_local.shiftwidth = 2
					vim.opt_local.softtabstop = 2
				end,
			})
		end,
	},
}
