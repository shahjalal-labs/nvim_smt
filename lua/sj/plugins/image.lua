-- ~/.config/nvim/lua/plugins/image.lua
return {
	{
		"3rd/image.nvim",
		build = false, -- skip native rock build
		enabled = false,
		opts = { -- pass options directly
			processor = "magick_cli", -- use ImageMagick CLI
			backend = "kitty", -- optional: "kitty", "ueberzug", "sixel"
			integrations = {
				markdown = {
					enabled = true,
					download_remote_images = true,
				},
			},
		},
	},
}
