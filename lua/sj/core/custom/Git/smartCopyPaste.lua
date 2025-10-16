--p: ╭──────────── Block Start ────────────╮
--t: readme generate prompt maker
-- 🔥 Generate AI-Ready README Prompt and Save to readmeGenerate.md

local uv = vim.loop

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return "File not found: " .. path
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function generate_readme_prompt()
	local output = {}

	-- 💡 Instruction Block at the Top
	table.insert(
		output,
		[[
Generate a professional, modern, and production-ready `README.md` file based on my project. Your entire  output **must be enclosed within a single markdown code block** using triple backticks and `markdown` as the language. Absolutely **no text should be outside** the code block. The structure, formatting, and content should follow **industry best practices** for open-source projects, with clearly separated sections (e.g., Features, Tech Stack, Installation, Folder Structure, License, etc.).

The markdown must:
- Use clear section headers (`##`) and subheaders (`###`) consistently
- Include emoji icons in section titles for modern visual appeal
- Apply bullet lists, tables, and code fences (` ``` `) for commands and code
- Be **ready to paste directly** into a markdown previewer with no extra modification
- Contain no redundant explanations or system-generated text outside the markdown block

Make sure this `README.md` looks visually appealing, easy to read, and suitable for developers on GitHub or other platforms. Output strictly in one markdown code block.
]]
	)

	local project_root = vim.fn.getcwd()

	-- 1. File Tree Structure
	vim.cmd("silent !tree -a -I 'node_modules|.git|dist|.cache' -L 4 > /tmp/project_structure.txt")
	local tree = read_file("/tmp/project_structure.txt")
	table.insert(output, "\n## 📁 File Structure\n```bash\n" .. tree .. "\n```")

	-- 2. package.json
	local pkg = read_file(project_root .. "/package.json")
	table.insert(output, "\n## 📦 package.json\n```json\n" .. pkg .. "\n```")

	-- 3. Route Files
	table.insert(output, "\n## 🗺️ Routes\n```js")
	local handle = io.popen("find src -type f -iname '*Route*.jsx'")
	if handle then
		for file in handle:lines() do
			table.insert(output, "// File: " .. file)
			table.insert(output, read_file(file))
		end
		handle:close()
	end
	table.insert(output, "```")

	-- 4. Existing README
	local readme = read_file(project_root .. "/README.md")
	table.insert(output, "\n## 📄 Existing README\n```md\n" .. readme .. "\n```")

	-- Final Prompt
	local final_prompt = table.concat(output, "\n\n")

	-- Save to file in CWD
	local out_path = project_root .. "/readmeGenerate.md"
	local f = io.open(out_path, "w")
	if f then
		f:write(final_prompt)
		f:close()
		vim.notify("✅ Prompt saved to readmeGenerate.md", vim.log.levels.INFO)
	end

	-- Copy to clipboard
	vim.fn.setreg("+", final_prompt)
	vim.notify("📋 Copied README prompt to clipboard", vim.log.levels.INFO)

	-- Open in vertical split
	vim.cmd("vsplit " .. out_path)
end

-- 🔑 Keybinding: <leader>yc
vim.keymap.set("n", "<leader>yc", generate_readme_prompt, {
	desc = "📄 Generate README prompt (AI-ready)",
})
--p: ╰───────────── Block End ─────────────╯
