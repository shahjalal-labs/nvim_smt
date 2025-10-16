---@type LazyPluginSpec
return {
	"arminveres/md-pdf.nvim",
	branch = "main",
	lazy = true,
	ft = { "markdown" },
	keys = {
		{
			"<leader>p,",
			function()
				require("md-pdf").convert_md_to_pdf()
			end,
			desc = "Convert Markdown to PDF",
		},
	},
	opts = {
		margins = "1.5cm",
		highlight = "tango",
		toc = true,
		preview_cmd = function()
			return "firefox"
		end,
		ignore_viewer_state = false,
		fonts = {
			main_font = nil,
			sans_font = "DejaVuSans",
			mono_font = "IosevkaTerm Nerd Font Mono",
			math_font = nil,
		},
		pandoc_user_args = {
			"-V geometry:margin=1.5cm",
			"--standalone=true",
		},
		output_path = "./",
		pdf_engine = "pdflatex",
	},
	config = function(_, opts)
		require("md-pdf").setup(opts)
	end,
}
