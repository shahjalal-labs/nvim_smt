--p: b
return {
	"APZelos/blamer.nvim",
	config = function()
		vim.g.blamer_enabled = true -- Enable on startup
		vim.g.blamer_delay = 500 -- Set delay to 500ms
		vim.g.blamer_show_in_visual_modes = 0 -- Disable in visual mode
		vim.g.blamer_show_in_insert_modes = 0 -- Disable in insert mode
		vim.g.blamer_prefix = " > " -- Prefix for blame message
		vim.g.blamer_template = "<committer> <summary>" -- Customize blame template
		vim.g.blamer_date_format = "%d/%m/%y" -- Date format
		vim.g.blamer_relative_time = 1 -- Show relative time
		vim.cmd([[ highlight Blamer guifg=lightgrey ]]) -- Highlight color
	end,
}
