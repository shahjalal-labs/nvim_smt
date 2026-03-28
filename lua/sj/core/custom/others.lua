-- Function to copy the current line diagnostic to the system clipboard
function copy_line_diagnosticC()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if diagnostics[1] then
		local message = diagnostics[1].message
		vim.fn.setreg("+", message) -- Copy to system clipboard
		print("Diagnostic copied to clipboard: " .. message)
	else
		print("No diagnostic on the current line")
	end
end

vim.api.nvim_set_keymap("n", "<space>dc", ":lua copy_line_diagnosticC()<CR>", { noremap = true, silent = true }) -- Copy diagnostic

-- Function to search the current line diagnostic message on Google
function google_search_diagnosticC()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if diagnostics[1] then
		local message = diagnostics[1].message
		-- URL-encode the message to make it safe for use in a URL
		local search_query =
			vim.fn.system("python3 -c 'import urllib.parse; print(urllib.parse.quote(\"" .. message .. "\"))'")
		local search_url = "https://www.google.com/search?q=" .. search_query:match("^%s*(.-)%s*$") -- trim whitespace
		vim.fn.jobstart({ "xdg-open", search_url }, { detach = true })
		print("Searching Google for: " .. message)
	else
		print("No diagnostic on the current line")
	end
end

vim.api.nvim_set_keymap("n", "<space>dg", ":lua google_search_diagnosticC()<CR>", { noremap = true, silent = true }) -- Google search diagnostic

-- Function to copy the current line diagnostic and open ChatGPT
function ask_chatgpt_about_diagnosticC()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if diagnostics[1] then
		local message = diagnostics[1].message
		-- Copy diagnostic message to clipboard
		vim.fn.setreg("+", message) -- Copies to system clipboard
		-- Open ChatGPT in the default browser
		vim.fn.jobstart({ "xdg-open", "https://chat.openai.com/" }, { detach = true })
		print("Diagnostic copied to clipboard. Opened ChatGPT; paste the message to ask.")
	else
		print("No diagnostic found on the current line")
	end
end

-- Key mappings for each diagnostic function
vim.api.nvim_set_keymap("n", "<space>da", ":lua ask_chatgpt_about_diagnosticC()<CR>", { noremap = true, silent = true }) -- Ask ChatGPT
--
--
--
--
--
-- Function to get the current date and time in the desired format
local function get_current_datetime()
	local date = os.date("*t")
	local formatted_date = string.format(
		"%02d/%02d/%04d %02d:%02d %s %s GMT+6 Sharifpur, Gazipur, Dhaka",
		date.day,
		date.month,
		date.year,
		date.hour % 12 == 0 and 12 or date.hour % 12,
		date.min,
		date.hour >= 12 and "PM" or "AM",
		os.date("%a")
	) -- Get abbreviated weekday
	return formatted_date
end

-- Function to insert the date comment at the top of the file
local function insert_date_comment()
	local filetype = vim.bo.filetype
	local comment_prefix

	if filetype == "javascript" or filetype == "typescript" then
		comment_prefix = "//w:"
	elseif filetype == "python" then
		comment_prefix = "#"
	elseif filetype == "lua" then
		comment_prefix = "--"
	else
		return
	end

	-- Move cursor to the first line and insert the date comment
	local date_comment = string.format("%s %s", comment_prefix, get_current_datetime())
	vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- Move cursor to the first line
	vim.api.nvim_put({ date_comment }, "l", false, true) -- Insert the comment
end

-- Autocommand to insert the date comment when a new file is created
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*",
	callback = insert_date_comment,
})
--
--
--
--
--
--w: 06/11/2024 01:44 PM Wed GMT+6 Sharifpur, Gazipur, Dhaka
--
--
--
--
--multiple line searching is not working it's need to be okay
--w:  Function to URL-encode text
local function url_encode(str)
	if str then
		str = string.gsub(str, "([^%w _%%%-%.~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		str = string.gsub(str, " ", "%%20") -- Encode spaces as %20
	end
	return str
end

-- ╭──────────── Block Start ────────────╮
-- Function to search Google with the current line or visual selection
function _G.search_google_selection()
	local query_text = ""

	if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
		-- Get start and end positions of the visual selection
		local start_line = vim.fn.line("'<")
		local end_line = vim.fn.line("'>")
		local start_col = vim.fn.col("'<")
		local end_col = vim.fn.col("'>")

		-- Get all lines within the selection range
		local lines = vim.fn.getline(start_line, end_line)

		-- Handle column-specific trimming for first and last lines
		if #lines == 1 then
			-- Single line selection within start and end columns
			query_text = string.sub(lines[1], start_col, end_col)
		else
			-- Multi-line selection: trim first and last lines to selected columns
			lines[1] = string.sub(lines[1], start_col)
			lines[#lines] = string.sub(lines[#lines], 1, end_col)
			query_text = table.concat(lines, " ") -- Concatenate all lines with spaces
		end

		-- Exit visual mode after capturing selection
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- If not in visual mode, use the current line
		query_text = vim.fn.getline(".")
	end

	-- URL-encode the query and construct search URL
	local encoded_query = url_encode(query_text)
	local search_url = "https://www.google.com/search?q=" .. encoded_query

	-- Open the URL in the default browser
	vim.fn.jobstart({ "xdg-open", search_url }, { detach = true })
end

-- Map `<leader>sg` to search Google with the current line or visual selection
vim.api.nvim_set_keymap("n", "<leader>sg", ":lua search_google_selection()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>sg", ":<C-u>lua search_google_selection()<CR>", { noremap = true, silent = true })

-- ╰───────────── Block End ─────────────╯

-- ╭──────────── Block Start ────────────╮
--
-- vim.keymap.set("n", "<leader>pj", function()
-- 	local jobdir = "/run/media/sj/developer/web/L1B11/career/JobDocuments/jobDescription/"
-- 	local base = jobdir .. "jd"
-- 	local ext = ".md"
--
-- 	-- Get clipboard content
-- 	local clipboard = vim.fn.system("wl-paste")
-- 	clipboard = clipboard:gsub("\r", "")
--
-- 	-- Find next available filename
-- 	local filename = base .. ext
-- 	local i = 1
-- 	while vim.fn.filereadable(filename) == 1 do
-- 		filename = base .. i .. ext
-- 		i = i + 1
-- 	end
--
-- 	-- Get current date
-- 	local date = os.date("%Y-%m-%d")
--
-- 	-- Build the full LLM prompt as markdown
-- 	local prompt = [[
-- ### 📋 LLM TASK INSTRUCTIONS
-- 📅 Date: ]] .. date .. [[
--
-- You are an expert job formatter.
--
-- ---
--
-- #### 🔧 Your Task:
-- 1. Read and **explain the job** in human-friendly detail: role, company, location, compensation, type.
-- 2. **Convert all currencies to BDT and monthly**, keeping the original .
-- 3. **Convert timezones to GMT+6** (Dhaka), keeping the original.
-- 4. **Categorize stack** into:
--    - ✅ Required stack
--    - 🔧 Mentioned/optional stack
-- 5. **Explain how to apply**, if mentioned (email, form, DM, etc.)
-- 7. My skills are: ["JavaScript", "Markdown", "Lua", "React", "React Router", "TanStack Query", "Tailwind CSS", "Node.js", "Express.js", "MongoDB", "Firebase", "JWT", "Surge", "Netlify", "Figma", "Neovim", "Tmux", "Zsh", "Kitty", "SurfingKeys", "Hyprland", "EndeavourOS", "HTML", "CSS"]
-- 8. I have hands on practice with professional course and projectsmore than 5
-- 9. so clarify how much the job requirement match with me
-- 10. I’ve completed 5+ hands-on real-world MERN projects, built with scalable architecture and CLI workflow.
--     Here are my best examples:
--
--       🌐 DeshGuide – Tourism Management System
--     🔗 Live: https://deshguide.surge.sh
--
--     💼 WorkElevate – Job Portal
--     🔗 Live: https://workelevate.surge.sh
--
--     🧑‍🍳 FlavorBook – Recipe Sharing + Marketplace
--     🔗 Live: https://flavor-book.surge.sh
--
--     🎓 EduVerse – Group Assignment Platform
--     🔗 Live: https://edu-verse.surge.sh
--
--     🖥️ My Portfolio (v2)
--     🔗 Live: https://shahjalal-labs.surge.sh
--     🚀 GitHub Profile: https://github.com/shahjalal-labs
--
-- 11. Based on the job description, rate how well my skills match this job:
--     - % match or keyword overlap
--     - Any strong alignment you find
--     - Mention projects from my GitHub that reflect this
--
-- 12. Give a match score out of 10 with a short reason.
--
-- 13. Tell me if the job supports or restricts my Linux-first terminal workflow (Hyprland, Tmux, Neovim, Zsh, Kitty, etc.)
--
-- 14. If the job includes frontend/backend stacks, suggest any gaps I should fill, e.g., missing skill or tool.
--
-- 15. If the company is named, provide:
--     - Quick company summary (size, country, sector)
--     - If remote, confirm timezone overlap with Bangladesh
--
-- 16. If any requirement looks vague, confusing, or a red flag, highlight it.
--
-- 17. **Then generate a README-style markdown summary** using this exact structure:
-- ```markdown
-- ---
-- ### 1. `🏢 Company Name — Job Title - (onsite/remote)- date - bdt salary`
--
-- <pre><code>
-- 📅 Applied On: foramt: 31/12/25 ]] .. date .. [[
-- 💰 Stipend/Salary : Original ≈ Converted BDT / Monthly
-- ⏰ Hours: Bangladesh Time → Original Timezone
-- 🧰 Stack: Required Tech Stack
-- ❌ Lack Stack: It will be  Dynamic not static – Based on Job Requirements: For your example added: mysql, postgres, redis, docker, nginx, aws, gcp, azure, firebase, netlify, surge, figma, sketch, etc.
-- 📆 Interview Date: (If known or write "Not yet scheduled")
-- 🌐 Location: Full Location + Timezone
-- 🧭 Platform: Source or Application method
-- ⏳ Status: 🟡 Pending or other
-- 📞  Follow-Up way:  career@remoteoffice.io
-- </code></pre>
--
-- 🔗 [Company Website](url) `url` <br />
-- 🔗 [Job Link](link) `link: first 30 chars...`
-- ---
--
-- ]] .. clipboard .. "\n```"
--
-- 	-- Write prompt to the file
-- 	local f = io.open(filename, "w")
-- 	if f then
-- 		f:write(prompt)
-- 		f:close()
-- 	else
-- 		vim.notify("❌ Failed to write job file", vim.log.levels.ERROR)
-- 		return
-- 	end
--
-- 	-- Open in current buffer
-- 	vim.cmd("edit " .. filename)
--
-- 	-- Copy prompt to system clipboard
-- 	vim.fn.system("wl-copy", prompt)
--
-- 	vim.notify("✅ JD prompt created: " .. vim.fn.fnamemodify(filename, ":t"))
-- end, { desc = "Create job prompt from clipboard (JD)" })
-- ╰───────────── Block End ─────────────╯
--
--
--

