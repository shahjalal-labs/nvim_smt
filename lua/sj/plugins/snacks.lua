return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	opts = {
		explorer = {
			enabled = true, -- Enables the built-in file explorer feature from snacks.nvim
		},

		picker = {
			enabled = true, -- Enables the picker UI for various search/navigation sources

			sources = {
				files = {
					hidden = true, -- Show hidden files when using the file picker
					ignored = false, -- Show ignored files (from .gitignore or similar)
				},

				explorer = {
					hidden = true, -- Show hidden files in the file explorer
					ignored = false, -- Show ignored files in the explorer
				},

				git_files = {
					hidden = false, -- Include hidden files when picking Git-tracked files
					ignored = false, -- Include ignored files when picking Git-tracked files
				},

				grep = {
					hidden = false, -- Search in hidden files with live grep
					ignored = false, -- Search in ignored files with live grep
				},

				grep_word = {
					hidden = false, -- Grep the current word (or visual selection) including hidden files
					ignored = false, -- Grep the current word including ignored files
				},

				grep_buffers = {
					hidden = false, -- Grep open buffers including hidden files
					ignored = false, -- Grep open buffers including ignored files
				},
			},
		},
		telescope = {
			defaults = {
				file_ignore_patterns = {
					"node_modules", -- ignore all node_modules
					"%.lock", -- ignore lockfiles
					"%.min.js", -- optionally ignore minified js
				},
			},
		},
	},
	keys = function()
		local Snacks = require("snacks")

		return {
			-- Top Pickers & Explorer
			{
				"<leader>,/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>,<space>",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>,si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>,:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>,,",
				function()
					Snacks.explorer()
				end,
				desc = "File Explorer",
			},
			{
				"<leader>,ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<M-j>",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>,gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>,fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>,sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>,sw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Grep Word or Visual Selection",
				mode = { "n", "x" },
			},
			{
				"<leader>,ad",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Git Diff (Hunks)",
			},
			{
				"<leader>,sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>,sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>,sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>,sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>,sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>,sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>,sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>,cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<leader>,gB",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "v" },
			},
			{
				"<leader>,gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>,un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss Notifications",
			},
			{
				"<leader>,e",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},

			{
				"<leader>,n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},

			-- Find
			{
				"<leader>,fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>,fc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},

			{
				"<leader>,fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},

			{
				"<leader>,fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},

			-- Git

			{
				"<leader>,gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>,gL",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>,gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>,gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},

			{
				"<leader>,gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "Git Log File",
			},

			-- Grep
			{
				"<leader>,sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>,sB",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},

			-- Search
			{
				'<leader>,sb"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>,s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>,sa",
				function()
					Snacks.picker.autocmds()
				end,
				desc = "Autocmds",
			},

			{
				"<leader>,sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>,sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>,sH",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Highlights",
			},

			{
				"<leader>,sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},

			{
				"<leader>,sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>,sp",
				function()
					Snacks.picker.lazy()
				end,
				desc = "Search Plugin Spec",
			},

			{
				"<leader>,sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume Last Picker",
			},
			{
				"<leader>,su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},

			-- LSP
			{
				"<leader>,gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"<leader>,gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"<leader>,gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"<leader>,gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"<leader>,gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto Type Definition",
			},
			{
				"<leader>,ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>,sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},

			-- Other
			{
				"<leader>,z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle Zen Mode",
			},
			{
				"<leader>,Z",
				function()
					Snacks.zen.zoom()
				end,
				desc = "Toggle Zoom",
			},
			{
				"<leader>,.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>,S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>,N",
				function()
					Snacks.win({
						file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
						width = 0.6,
						height = 0.6,
						wo = {
							spell = false,
							wrap = false,
							signcolumn = "yes",
							statuscolumn = " ",
							conceallevel = 3,
						},
					})
				end,
				desc = "Neovim News",
			},
			{
				"<leader>,bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},

			-- Terminal
			{
				"<leader>,_",
				function()
					Snacks.terminal()
				end,
				desc = "Toggle Terminal",
			},

			-- Word Navigation
			{
				"<leader>,]]",
				function()
					Snacks.words.jump(vim.v.count1)
				end,
				desc = "Next Reference",
				mode = { "n", "t" },
			},
			{
				"<leader>,[[",
				function()
					Snacks.words.jump(-vim.v.count1)
				end,
				desc = "Prev Reference",
				mode = { "n", "t" },
			},
		}
	end,
}
