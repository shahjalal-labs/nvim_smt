vim.keymap.set("n", "<leader>mm", function()
	-- Get current file path and directory
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		print("No file detected!")
		return
	end

	local dir = vim.fn.fnamemodify(file_path, ":h") -- folder path
	local base = vim.fn.fnamemodify(file_path, ":t:r") -- filename without extension
	local img_file = string.format("%s/%s.png", dir, base) -- full path for image

	-- Check if 'wl-paste' is installed
	if vim.fn.executable("wl-paste") == 0 then
		print("Error: wl-paste is not installed. Install wl-clipboard package.")
		return
	end

	-- Save clipboard image (Wayland)
	local save_cmd = string.format("wl-paste --type image/png > '%s'", img_file)
	local result = os.execute(save_cmd)

	if result ~= 0 then
		print("Failed to save image from clipboard. Make sure your clipboard has a PNG image.")
		return
	end

	-- Insert markdown link at cursor
	local markdown_link = string.format("![%s](%s.png)", base, base)
	vim.api.nvim_put({ markdown_link }, "l", true, true) -- linewise

	print("Saved clipboard image as " .. img_file)
	print("Markdown link inserted: " .. markdown_link)
end, { noremap = true, silent = false })
