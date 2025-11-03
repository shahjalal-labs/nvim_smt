-- In your Neovim config (e.g. ~/.config/nvim/lua/keymaps.lua)
vim.keymap.set("n", "<leader>fm", function()
	-- Get clipboard content
	local clipboard = vim.fn.getreg("+"):gsub("%s+", "")
	if clipboard == "" then
		print("Clipboard empty — nothing to make.")
		return
	end

	-- Normalize naming
	local folder = clipboard:sub(1, 1):upper() .. clipboard:sub(2)
	local filebase = clipboard:sub(1, 1):lower() .. clipboard:sub(2)

	-- Target path
	local base_path = "./src/app/module/" .. folder
	vim.fn.mkdir(base_path, "p") -- create folder if needed, no error if exists

	-- Define files
	local files = {
		filebase .. ".controller.ts",
		filebase .. ".service.ts",
		filebase .. ".routes.ts",
	}

	-- Create files if missing
	for _, file in ipairs(files) do
		local fullpath = base_path .. "/" .. file
		if vim.fn.filereadable(fullpath) == 0 then
			vim.fn.writefile({}, fullpath)
			print("Created: " .. fullpath)
		else
			print("Exists: " .. fullpath)
		end
	end
end, { desc = "Make module files from clipboard" })
