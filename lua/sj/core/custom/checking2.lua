-- take screenshot by slurp and automatic save into src/assets/screenshots/ss-09-00-04-AM_28-03-26.png  and  paste into markdown like ![Screenshot](src/assets/screenshots/ss-09-00-04-AM_28-03-26.png)

--w: (start)╭────────────  take screenshot by slurp  ────────────╮
vim.keymap.set("n", "<leader>sw", function()
	local cwd = vim.fn.getcwd()
	local screenshots_dir = cwd .. "/src/assets/screenshots"
	local readme_path = cwd .. "/README.md"

	-- Ensure screenshots directory exists
	vim.fn.mkdir(screenshots_dir, "p")

	-- Compose the bash screenshot command
	local bash_cmd = string.format(
		[[
    f="%s/ss-$(LC_TIME=C date +%%I-%%M-%%S-%%p_%%d-%%m-%%y).png";
    grim -g "$(slurp)" "$f" &&
    wl-copy --type image/png < "$f" &&
    echo "![Screenshot](src/assets/screenshots/$(basename "$f"))"
  ]],
		screenshots_dir
	)

	-- Run bash command and capture markdown image line
	local output = vim.fn.systemlist({ "bash", "-c", bash_cmd })

	if output and #output > 0 then
		local md_line = output[1]

		-- Append markdown line to README.md
		local file = io.open(readme_path, "a")
		if file then
			file:write("\n" .. md_line .. "\n")
			file:close()
			print("🖼️ Screenshot saved and appended to README.md")
		else
			print("❌ Failed to open README.md for appending")
		end
	else
		print("❌ Screenshot failed")
	end
end, { desc = "Area select screenshot + append markdown to README.md" })
--w: (end)  ╰────────────  take screenshot by slurp  ────────────╯

--send mail from neovim

--[[ local M = {}

local RESUME = "/home/sj/Downloads/Shahjalal_Resume.pdf"
local BODY_FILE = "/tmp/nvim_mail.txt"

-- Open email composer
M.open_mail = function()
	vim.cmd("vsplit")
	vim.cmd("wincmd L")

	-- create scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)

	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	-- get clipboard content
	local clipboard = vim.fn.getreg("+") or ""

	local template = {
		"Subject:",
		"To:",
		"",
		"Body:",
		"",
		"Assalamu Alaikum,",
		"",
	}

	-- insert clipboard content into body
	for line in clipboard:gmatch("[^\r\n]+") do
		table.insert(template, line)
	end

	-- closing
	vim.list_extend(template, {
		"",
		"Best regards,",
		"Md. Shahjalal",
		"",
		"Resume: https://drive.google.com/file/d/1eKx1OO7p2tvSIxPKD1aDHu6sgPkVcJwN/view",
		"Github: https://github.com/shahjalal-labs",
		"Portfolio: https://shahjalal-labs.surge.sh",
		"Linkedin: https://www.linkedin.com/in/shahjalal-labs",
		"Fb: https://www.facebook.com/shahjalal.labs",
	})

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)

	-- keymap: press q to close
	vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = buf, silent = true })

	print("Fill Subject & To → <leader>ss to send | q to close")
end

-- Send email
M.send_mail = function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local subject = ""
	local to = ""
	local body = {}
	local in_body = false

	for _, line in ipairs(lines) do
		if line:match("^Subject:") then
			subject = vim.trim(line:gsub("^Subject:%s*", ""))
		elseif line:match("^To:") then
			to = vim.trim(line:gsub("^To:%s*", ""))
		elseif line:match("^Body:") then
			in_body = true
		elseif in_body then
			table.insert(body, line)
		end
	end

	if subject == "" or to == "" then
		print("❌ Subject or To is empty")
		return
	end

	-- write body to temp file
	local f = io.open(BODY_FILE, "w")
	f:write(table.concat(body, "\n"))
	f:close()

	-- use -i (IMPORTANT: prevents double attachment)
	local cmd = string.format("mutt -s '%s' -i '%s' -a '%s' -- '%s'", subject, BODY_FILE, RESUME, to)

	os.execute(cmd)

	print("✅ Email sent")

	-- close buffer after send
	vim.cmd("bd!")
end

-- keybindings
vim.keymap.set("n", "<leader>es", M.open_mail, { desc = "Email Start" })
vim.keymap.set("n", "<leader>ss", M.send_mail, { desc = "Send Email" }) ]]

-- claude
--
--

local M = {}

local RESUME = "/home/sj/Downloads/Shahjalal_Resume.pdf"
local BODY_FILE = "/tmp/nvim_mail.txt"

-- Open email composer
M.open_mail = function()
	vim.cmd("vsplit")
	vim.cmd("wincmd L")

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false

	local clipboard = vim.fn.getreg("+") or ""
	local template = {
		"Subject:",
		"To:",
		"",
		"Body:",
		"",
		"Assalamu Alaikum,",
		"",
	}

	for line in clipboard:gmatch("[^\r\n]+") do
		table.insert(template, line)
	end

	vim.list_extend(template, {
		"",
		"Best regards,",
		"Md. Shahjalal",
		"",
		"Resume: https://drive.google.com/file/d/1eKx1OO7p2tvSIxPKD1aDHu6sgPkVcJwN/view",
		"Github: https://github.com/shahjalal-labs",
		"Portfolio: https://shahjalal-labs.surge.sh",
		"Linkedin: https://www.linkedin.com/in/shahjalal-labs",
		"Fb: https://www.facebook.com/shahjalal.labs",
	})

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)

	vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = buf, silent = true })
	print("Fill Subject & To → <leader>ss to send | q to close")
end

-- Send email
M.send_mail = function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local subject = ""
	local to = ""
	local body = {}
	local in_body = false

	for _, line in ipairs(lines) do
		if line:match("^Subject:") then
			subject = vim.trim(line:gsub("^Subject:%s*", ""))
		elseif line:match("^To:") then
			to = vim.trim(line:gsub("^To:%s*", ""))
		elseif line:match("^Body:") then
			in_body = true
		elseif in_body then
			table.insert(body, line)
		end
	end

	if subject == "" or to == "" then
		print("❌ Subject or To is empty")
		return
	end

	local f = io.open(BODY_FILE, "w")
	f:write(table.concat(body, "\n"))
	f:close()

	-- Pipe via stdin to avoid mutt opening interactive editor
	local cmd = string.format("cat '%s' | mutt -s '%s' -a '%s' -- '%s'", BODY_FILE, subject, RESUME, to)

	local result = os.execute(cmd)

	if result == 0 then
		print("✅ Email sent to " .. to)
		vim.cmd("bd!")
	else
		print("❌ Failed to send email")
	end
end

-- Keybindings
vim.keymap.set("n", "<leader>es", M.open_mail, { desc = "Email Start" })
vim.keymap.set("n", "<leader>ss", M.send_mail, { desc = "Send Email" })

return M
