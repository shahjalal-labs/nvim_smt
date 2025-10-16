-- Enhanced vim-matchup configuration
return {
	"andymass/vim-matchup",
	config = function()
		-- Show offscreen matches in a popup window
		vim.g.matchup_matchparen_offscreen = {
			method = "popup",
			fullwidth = 1,
			highlight = "Normal",
			border = "rounded",
		}

		-- Performance options
		vim.g.matchup_matchparen_deferred = 1
		vim.g.matchup_matchparen_timeout = 100
		vim.g.matchup_matchparen_insert_timeout = 30

		-- Enhanced highlighting
		vim.g.matchup_matchparen_hi_surround_always = 1
		vim.g.matchup_surround_enabled = 1

		-- Module configuration
		vim.g.matchup_transmute_enabled = 1
		vim.g.matchup_mouse_enabled = 0 -- Disable mouse features

		-- Additional text objects
		vim.g.matchup_text_obj_enabled = 1
		vim.g.matchup_delim_noskips = 2 -- Don't skip comments
	end,
}
