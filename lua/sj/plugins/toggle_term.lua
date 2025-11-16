-- toggleterm.nvim full feature setup with keybinds for Lazy.nvim

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			-- Key to toggle default terminal
			open_mapping = [[<C-\>]],

			-- Terminal layout: horizontal, vertical, float, tab
			direction = "float",

			-- Dynamic sizing
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.35
				end
			end,

			-- Automatically enter insert mode
			start_in_insert = true,

			-- Terminal persists when toggled
			persist_size = true,
			persist_mode = true,

			-- Close terminal when underlying process exits
			close_on_exit = true,

			-- Floating window options
			float_opts = {
				border = "curved",
				width = 110,
				height = 28,
				winblend = 0,
			},
		})

		---------------------------------------------------------------------------
		-- Keymaps for navigation + terminal mode behavior
		---------------------------------------------------------------------------
		local opts = { noremap = true, silent = true }

		-- Exit terminal to normal mode
		vim.api.nvim_set_keymap("t", "<esc>", [[<C-\><C-n>]], opts)

		-- Terminal window navigation
		vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
		vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
		vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
		vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)

		---------------------------------------------------------------------------
		-- Special terminals: lazygit, python, node, htop, etc.
		---------------------------------------------------------------------------
		local Terminal = require("toggleterm.terminal").Terminal

		-- Lazygit floating terminal
		local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
		function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end
		vim.keymap.set("n", "<leader>gg", _LAZYGIT_TOGGLE, opts)

		-- Python REPL
		local py = Terminal:new({ cmd = "python", hidden = true })
		function _PYTHON_TOGGLE()
			py:toggle()
		end
		vim.keymap.set("n", "<leader>py", _PYTHON_TOGGLE, opts)

		-- Node REPL
		local node = Terminal:new({ cmd = "node", hidden = true })
		function _NODE_TOGGLE()
			node:toggle()
		end
		vim.keymap.set("n", "<leader>nd", _NODE_TOGGLE, opts)

		-- Htop
		local htop = Terminal:new({ cmd = "htop", hidden = true, direction = "float" })
		function _HTOP_TOGGLE()
			htop:toggle()
		end
		vim.keymap.set("n", "<leader>ht", _HTOP_TOGGLE, opts)

		---------------------------------------------------------------------------
		-- Terminal counts: open multiple terminals
		---------------------------------------------------------------------------
		-- 1<C-\> => toggle terminal 1
		-- 2<C-\> => toggle terminal 2
		-- Already supported by default behavior of toggleterm
	end,
}
