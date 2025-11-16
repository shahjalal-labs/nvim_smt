-- In your Neovim config (e.g. ~/.config/nvim/lua/keymaps.lua)

vim.keymap.set("n", "<leader>fg", function()
	-- Get clipboard content
	local clipboard = vim.fn.getreg("+"):gsub("%s+", "")
	if clipboard == "" then
		print("Clipboard empty — nothing to make.")
		return
	end

	-- Normalize naming
	local folder = clipboard:sub(1, 1):upper() .. clipboard:sub(2)
	local filebase = clipboard:sub(1, 1):lower() .. clipboard:sub(2)

	-- Check which base directory exists
	local base_dirs = { "./src/app/module/", "./src/app/modules/" }
	local base_path = nil

	for _, dir in ipairs(base_dirs) do
		if vim.fn.isdirectory(dir) == 1 then
			base_path = dir .. folder
			break
		end
	end

	-- If neither exists, use modules as default
	if not base_path then
		base_path = "./src/app/modules/" .. folder
	end

	vim.fn.mkdir(base_path, "p") -- create folder if needed, no error if exists

	-- Define files (added validation)
	local files = {
		filebase .. ".controller.ts",
		filebase .. ".service.ts",
		filebase .. ".routes.ts",
		filebase .. ".validation.ts",
		filebase .. ".api.hurl",
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
