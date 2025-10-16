-- Optional mappings (customize as needed)
vim.keymap.set("n", "gxx", "<esc>:URLOpenUnderCursor<cr>")
vim.keymap.set("n", "gxh", "<esc>:URLOpenHighlightAll<cr>")
vim.keymap.set("n", "gxl", "<esc>:URLOpenHighlightAllClear<cr>")
return {
	"sontungexpt/url-open",
	event = "VeryLazy",
	cmd = "URLOpenUnderCursor",
	config = function()
		local status_ok, url_open = pcall(require, "url-open")
		if not status_ok then
			return
		end
		url_open.setup({})
	end,
}
