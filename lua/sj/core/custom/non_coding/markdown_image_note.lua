-- Save the current clipboard image to the same directory of the active file, using the same filename but with a .png extension. Then insert a link to that image into the current Markdown file.
--w: (start)╭────────────  markdown image note ────────────╮
vim.keymap.set("n", "<leader>mm", function()
	-- Get current file path and directory
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		print("No file detected!")
		return
	end

	local dir = vim.fn.fnamemodify(file_path, ":h")
	local base = vim.fn.fnamemodify(file_path, ":t:r")

	-- Check if 'wl-paste' is installed
	if vim.fn.executable("wl-paste") == 0 then
		print("Error: wl-paste is not installed. Install wl-clipboard package.")
		return
	end

	-- Generate unique filename
	local index = 1
	local img_file
	local img_name

	while true do
		if index == 1 then
			img_name = base
		else
			img_name = string.format("%s-%d", base, index)
		end

		img_file = string.format("%s/%s.png", dir, img_name)

		if vim.fn.filereadable(img_file) == 0 then
			break
		end

		index = index + 1
	end

	-- Save clipboard image
	local save_cmd = string.format("wl-paste --type image/png > '%s'", img_file)
	local result = os.execute(save_cmd)

	if result ~= 0 then
		print("Failed to save image from clipboard. Make sure your clipboard has a PNG image.")
		return
	end

	-- Insert markdown link
	local markdown_link = string.format("![%s](%s.png)", img_name, img_name)
	vim.api.nvim_put({ markdown_link }, "l", true, true)

	print("Saved clipboard image as " .. img_file)
	print("Markdown link inserted: " .. markdown_link)
end, {
	noremap = true,
	desc = "Save clipboard image and insert markdown link",
	silent = false,
})
--w: (end)  ╰────────────  markdown image note ────────────╯
