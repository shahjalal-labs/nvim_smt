-- Decode JWT token from clipboard
--[[ local function decode_jwt()
	-- Get clipboard content
	local jwt = vim.fn.getreg("+")
	if jwt == "" then
		jwt = vim.fn.getreg("*")
	end

	if jwt == "" then
		vim.notify("Clipboard is empty!", vim.log.levels.WARN)
		return
	end

	-- Extract payload part (second part of JWT)
	local parts = {}
	for part in jwt:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	if #parts < 2 then
		vim.notify("Invalid JWT token format", vim.log.levels.ERROR)
		return
	end

	local payload = parts[2]

	-- Add padding if needed and decode base64
	local padding = (#payload % 4 == 0) and "" or string.rep("=", 4 - (#payload % 4))
	payload = payload .. padding

	local decoded = vim.fn.system('echo "' .. payload .. '" | base64 -d 2>/dev/null')

	if decoded == "" then
		vim.notify("Failed to decode JWT", vim.log.levels.ERROR)
		return
	end

	-- Format JSON if jq is available, otherwise use as-is
	local formatted = vim.fn.system("echo '" .. decoded .. "' | jq . 2>/dev/null")
	if formatted ~= "" and vim.v.shell_error == 0 then
		decoded = formatted
	end

	-- Create a new temporary buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "JWT_Decoded_" .. os.time())

	-- Set buffer options to make it temporary
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)

	-- Split window and show buffer
	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)

	-- Set the decoded content
	local lines = vim.split(decoded, "\n")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set filetype to json for syntax highlighting
	vim.api.nvim_buf_set_option(buf, "filetype", "json")

	-- Make buffer readonly
	vim.api.nvim_buf_set_option(buf, "readonly", true)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	vim.notify("JWT decoded successfully!")
end

-- Create key mapping
vim.keymap.set("n", "<leader>dj", decode_jwt, { desc = "Decode JWT from clipboard" }) ]]

-- Decode JWT token from clipboard
local function decode_jwt()
	-- Get clipboard content
	local jwt = vim.fn.getreg("+")
	if jwt == "" then
		jwt = vim.fn.getreg("*")
	end

	if jwt == "" then
		vim.notify("Clipboard is empty!", vim.log.levels.WARN)
		return
	end

	-- Extract payload part (second part of JWT)
	local parts = {}
	for part in jwt:gmatch("[^.]+") do
		table.insert(parts, part)
	end

	if #parts < 2 then
		vim.notify("Invalid JWT token format", vim.log.levels.ERROR)
		return
	end

	local payload = parts[2]

	-- Add padding if needed and decode base64
	local padding = (#payload % 4 == 0) and "" or string.rep("=", 4 - (#payload % 4))
	payload = payload .. padding

	local decoded = vim.fn.system('echo "' .. payload .. '" | base64 -d 2>/dev/null')

	if decoded == "" then
		vim.notify("Failed to decode JWT", vim.log.levels.ERROR)
		return
	end

	-- Format JSON if jq is available, otherwise use as-is
	local formatted = vim.fn.system("echo '" .. decoded .. "' | jq . 2>/dev/null")
	if formatted ~= "" and vim.v.shell_error == 0 then
		decoded = formatted
	end

	-- Create a new temporary buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "JWT_Decoded_" .. os.time())

	-- Set buffer options to make it temporary
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)

	-- Vertical split and show buffer
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)

	-- Set the decoded content
	local lines = vim.split(decoded, "\n")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set filetype to json for syntax highlighting
	vim.api.nvim_buf_set_option(buf, "filetype", "json")

	-- Make buffer readonly
	vim.api.nvim_buf_set_option(buf, "readonly", true)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Add keymap to close buffer with 'q'
	vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, noremap = true, silent = true })

	vim.notify("JWT decoded successfully! Press 'q' to close.")
end

-- Create key mapping
vim.keymap.set("n", "<leader>dj", decode_jwt, { desc = "Decode JWT from clipboard" })
