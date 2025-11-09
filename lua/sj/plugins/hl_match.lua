return {
	{
		"rareitems/hl_match_area.nvim",
		config = function()
			require("hl_match_area").setup()
			-- Optionally, customize the highlight color, for example:
			-- vim.api.nvim_set_hl(0, 'MatchArea', { bg = "#FFFFFF" })
		end,
	},
	-- other plugins ...
}
