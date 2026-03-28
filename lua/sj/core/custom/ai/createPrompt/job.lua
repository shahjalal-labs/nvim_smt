--w: ╭──────────── Block Start ────────────╮
-- Create new job description prompt with auto-incremented Tracker number
vim.keymap.set("n", "<leader>jr", function()
	local jobdir = "/run/media/sj/developer/web/L1B11/career/JobDocuments/jobDescription/"
	local tracker_path = "/run/media/sj/developer/web/L1B11/career/JobDocuments/Tracker/Tracker.md"
	local base = jobdir .. "jd"
	local ext = ".md"

	-- Read Tracker.md to find the last job number
	local tracker_content = vim.fn.readfile(tracker_path)
	local last_number = nil
	for i = #tracker_content, 1, -1 do
		local line = tracker_content[i]
		local num = line:match("^###%s*(%d+%.%d+)%s*`🏢")
		if num then
			last_number = num
			break
		end
	end

	if not last_number then
		vim.notify("❌ Could not find last number in Tracker.md", vim.log.levels.ERROR)
		return
	end

	-- Increment both major and minor parts
	local major, minor = last_number:match("(%d+)%.(%d+)")
	major, minor = tonumber(major), tonumber(minor)
	major = major + 1
	minor = minor + 1
	local new_number = string.format("%d.%02d", major, minor)

	-- Get clipboard content
	local clipboard = vim.fn.system("wl-paste")
	clipboard = clipboard:gsub("\r", "")

	-- Find next available filename
	local filename = base .. ext
	local i = 1
	while vim.fn.filereadable(filename) == 1 do
		filename = base .. i .. ext
		i = i + 1
	end

	-- Current date
	local date = os.date("%Y-%m-%d")

	-- Build the LLM prompt
	local prompt = [[
### 📋 LLM TASK INSTRUCTIONS  
📅 Date: ]] .. date .. [[

You are an expert job formatter.

---

#### 🔧 Your Task:
1. Read and **explain the job** in human-friendly detail: role, company, location, compensation, type.  
2. **Convert all currencies to BDT and monthly**, keeping the original .  
3. **Convert timezones to GMT+6** (Dhaka), keeping the original.  
4. **Categorize stack** into:  
   - ✅ Required stack  
   - 🔧 Mentioned/optional stack  
5. **Explain how to apply**, if mentioned (email, form, DM, etc.)  
7. My skills are: ["JavaScript", "Markdown", "Lua", "React", "React Router", "TanStack Query", "Tailwind CSS", "Node.js", "Express.js", "MongoDB", "Firebase", "JWT", "Surge", "Netlify", "Figma", "Neovim", "Tmux", "Zsh", "Kitty", "SurfingKeys", "Hyprland", "EndeavourOS", "HTML", "CSS"]
8. I have hands on practice with professional course and projectsmore than 5
9. so clarify how much the job requirement match with me 
10. I’ve completed 5+ hands-on real-world MERN projects, built with scalable architecture and CLI workflow.  
    Here are my best examples:

    🌐 DeshGuide – Tourism Management System  
    🔗 Live: https://deshguide.surge.sh

    🎓 EduVerse – Group Assignment Platform  
    🔗 Live: https://edu-verse.surge.sh

    🧑‍🍳 FlavorBook – Recipe Sharing + Marketplace  
    🔗 Live: https://flavor-book.surge.sh

    💼 WorkElevate – Job Portal  
    🔗 Live: https://workelevate.surge.sh

    🖥️ My Portfolio (v2)  
    🔗 Live: https://shahjalal-labs.surge.sh
    🚀 GitHub Profile: https://github.com/shahjalal-labs

11. Based on the job description, rate how well my skills match this job:  
    - % match or keyword overlap  
    - Any strong alignment you find  
    - Mention projects from my GitHub that reflect this

12. Give a match score out of 10 with a short reason.

13. Tell me if the job supports or restricts my Linux-first terminal workflow (Hyprland, Tmux, Neovim, Zsh, Kitty, etc.)

14. If the job includes frontend/backend stacks, suggest any gaps I should fill, e.g., missing skill or tool.

15. If the company is named, provide:  
    - Quick company summary (size, country, sector)  
    - If remote, confirm timezone overlap with Bangladesh

16. If any requirement looks vague, confusing, or a red flag, highlight it.

17. If the job description requires an email application, draft a professional email of 100–150 words in a clear and formal tone. Do not use emojis. Exclude the closing signature since a professional one is already in place. Do not include personal links. Write the email body inside a code block, while placing the subject line and recipient (“To”) outside the code block. Highlight only MERN and Next.js skills, and avoid mentioning any other experience or skills.

18. **Then generate a README-style markdown summary** using this exact structure in the markdown don't keep extra data. markdown summary strictly from ### number to down the job link line and the final --- :
```markdown
### ]] .. new_number .. [[ `🏢 Company Name — Job Title - onsite/remote - date with foramt: 31/12/25 - BDT salary`

<pre><code>
📅 Applied On: foramt: 31/12/25 ]] .. date .. [[
💰 Stipend/Salary : Original ≈ Converted BDT / Monthly
⏰ Hours: Bangladesh Time → Original Timezone
🧰 Stack: Required Tech Stack
❌ Lack Stack: It will be  Dynamic not static – Based on Job Requirements: For your example added: mysql, postgres, redis, docker, nginx, aws, gcp, azure, firebase, netlify, surge, figma, sketch, etc.
📆 Interview Date: (If known or write "Not yet scheduled")
🌐 Location: Full Location + Timezone
🧭 Platform: Source or Application method
⏳ Status: 🟡 Pending or other
📞  Follow-Up way:  career@remoteoffice.io
</code></pre>

🔗 [Company Website](url) `url` <br />
🔗 [Job Link](link) `link: first 30 chars...`
---

]] .. clipboard .. "\n```"

	-- Write to file
	local f = io.open(filename, "w")
	if f then
		f:write(prompt)
		f:close()
	else
		vim.notify("❌ Failed to write job file", vim.log.levels.ERROR)
		return
	end

	-- Open file and copy prompt to clipboard
	vim.cmd("edit " .. filename)
	vim.fn.system("wl-copy", prompt)

	vim.notify("✅ JD prompt created: " .. vim.fn.fnamemodify(filename, ":t") .. " (" .. new_number .. ")")
end, { desc = "Create job prompt from clipboard (JD)" })
--w: ╰───────────── Block End ─────────────╯

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
