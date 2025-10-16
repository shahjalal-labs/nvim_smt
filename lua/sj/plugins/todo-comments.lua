return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local todo_comments = require("todo-comments")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })

		keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })

		-- Setup todo-comments with your desired configuration
		todo_comments.setup({
			signs = true, -- show icons in the signs column
			sign_priority = 8, -- sign priority
			keywords = {
				FIX = {
					icon = " ", -- icon used for the sign, and in search results
					color = "error", -- can be a hex color, or a named color (see below)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- alternative keywords
				},
				t = { icon = " ", color = "error" },
				h = { icon = " ", color = "warning" },
				w = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				p = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				n = { icon = " ", color = "hint", alt = { "INFO" } },
				te = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			gui_style = {
				fg = "NONE", -- The gui style to use for the fg highlight group.
				bg = "BOLD", -- The gui style to use for the bg highlight group.
			},
			merge_keywords = true, -- merge custom keywords with default ones
			highlight = {
				multiline = true, -- enable multiline todo comments
				multiline_pattern = "^.", -- lua pattern to match the next multiline
				multiline_context = 10, -- extra lines for context
				before = "", -- highlight before keyword
				keyword = "wide", -- highlight keyword (wide, wide_bg, etc.)
				after = "fg", -- highlight after the keyword
				pattern = [[.*<(KEYWORDS)\s*:]], -- pattern for highlighting
				comments_only = true, -- use treesitter to match in comments only
				max_line_len = 400, -- ignore lines longer than this
				exclude = {}, -- file types to exclude
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#00E5FF" },
				default = { "Identifier", "#76FF03" },
				test = { "Identifier", "#FF00FF" },
			},
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				-- regex that will be used to match keywords.
				-- don't replace the (KEYWORDS) placeholder
				pattern = [[\b(KEYWORDS):]], -- ripgrep regex
			},
		})
	end,
}
