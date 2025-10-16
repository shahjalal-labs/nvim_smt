--p: ╭──────────── Block Start ────────────╮
--t: readme generate prompt maker with dynamic detailed tables + preview section
-- 🔥 Generate AI-Ready README Prompt with dynamic routing tables and UI preview

local uv = vim.loop
local project_root = vim.fn.getcwd()

-- Helper: Read file
local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return "File not found: " .. path
	end
	local content = file:read("*a")
	file:close()
	return content
end

-- Helper: Extract title from filename (e.g., homepage1.jpg → Homepage)
local function extract_title(filename)
	local name = filename:match("([^/\\]+)%d*%..+$") or filename
	name = name:gsub("([a-z])([A-Z])", "%1 %2") -- camelCase split
	name = name:gsub("[-_]", " ") -- kebab_case or snake_case to spaces
	name = name:sub(1, 1):upper() .. name:sub(2)
	return name
end

-- Helper: Case-insensitive folder finder
local function find_folder_case_insensitive(base, target)
	local handle = io.popen('ls -1 "' .. base .. '" 2>/dev/null')
	if not handle then
		return nil
	end
	for name in handle:lines() do
		if name:lower() == target:lower() then
			handle:close()
			return name
		end
	end
	handle:close()
	return nil
end

-- Helper: Recursively get all image files under a folder (including subfolders)
local function get_all_images_recursive(folder)
	local files = {}
	local handle = io.popen(
		'find "'
			.. folder
			.. '" -type f \\( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \\) 2>/dev/null'
	)
	if handle then
		for filepath in handle:lines() do
			-- Only relative path after project_root
			local rel_path = filepath:sub(#project_root + 2)
			table.insert(files, rel_path)
		end
		handle:close()
	end
	return files
end

-- Helper: Group files by immediate subfolder under device folder (or "" if no subfolder)
local function group_files_by_subfolder(device_folder, files)
	local grouped = {}
	for _, f in ipairs(files) do
		-- Extract subfolder after device folder, e.g. src/assets/images/preview/Desktop/Create/abc.png → Create
		local pattern = device_folder .. "/([^/]+)/"
		local subfolder = f:match(pattern)
		if not subfolder then
			-- File directly inside device folder without subfolder
			subfolder = ""
		end
		grouped[subfolder] = grouped[subfolder] or {}
		table.insert(grouped[subfolder], f)
	end
	return grouped
end

-- Helper: Sort files by numeric suffix before extension
local function sort_files_by_number(files)
	table.sort(files, function(a, b)
		local a_num = tonumber(a:match("(%d+)%.[^%.]+$")) or 0
		local b_num = tonumber(b:match("(%d+)%.[^%.]+$")) or 0
		return a_num < b_num
	end)
end

-- Build preview section markdown dynamically
local function build_preview_section()
	local preview = { "\n## 🖼️ UI Preview Section\n" }
	local base_preview_path = project_root .. "/src/assets/images/preview"

	local devices = { "Desktop", "Laptop", "Mobile" }
	local device_emojis = {
		Desktop = "🖥️ Desktop View",
		Laptop = "💻 Laptop View",
		Mobile = "📱 Mobile View",
	}

	for _, device in ipairs(devices) do
		local folder_name = find_folder_case_insensitive(base_preview_path, device)
		table.insert(preview, "### " .. (device_emojis[device] or device) .. "\n")

		if not folder_name then
			table.insert(preview, "_No preview folder found for " .. device .. "._\n")
		else
			local full_device_path = base_preview_path .. "/" .. folder_name
			local files = get_all_images_recursive(full_device_path)

			if #files == 0 then
				table.insert(preview, "_No images found in " .. device_emojis[device] .. "._\n")
			else
				local grouped = group_files_by_subfolder(full_device_path, files)
				local subfolders = {}

				for k in pairs(grouped) do
					table.insert(subfolders, k)
				end
				table.sort(subfolders, function(a, b)
					-- Put empty string "" (files in root) first
					if a == "" then
						return true
					end
					if b == "" then
						return false
					end
					return a:lower() < b:lower()
				end)

				for _, sub in ipairs(subfolders) do
					if sub ~= "" then
						table.insert(preview, "#### " .. sub .. "\n")
					end

					local imgs = grouped[sub]
					sort_files_by_number(imgs)

					for _, img_path in ipairs(imgs) do
						local filename = img_path:match("([^/]+)$")
						local title = extract_title(filename)
						table.insert(preview, string.format("**%s**  \n![](<%s>)\n", title, img_path))
					end

					-- If empty subfolder (no images)
					if #imgs == 0 and sub ~= "" then
						table.insert(preview, "_No images found in " .. sub .. "._\n")
					end
				end
			end
		end
	end
	return table.concat(preview, "\n")
end

-- Generate the full README prompt including dynamic routing tables and preview section
local function generate_readme_prompt_full()
	local output = {}

	-- Prompt instructions
	table.insert(
		output,
		[[
Generate a professional, modern, and production-ready `README.md` file based on my project. Your entire output **must be enclosed within a single markdown code block** using triple backticks and `markdown` as the language. Absolutely **no text should be outside** the code block. The structure, formatting, and content should follow **industry best practices** for open-source projects, with clearly separated sections (e.g., Features, Tech Stack, Installation, Routing & Folder Structure, License, Contribution, etc.).

The markdown must:
- Your entire output must be inside one **single** markdown code block using triple backticks (```) and `markdown` as the language.
- Use clear section headers (`##`) and subheaders (`###`) consistently.
- Include emoji icons in section titles for modern visual appeal.
- Apply bullet lists, tables, and code fences (``` ) for commands and code.
- Include **three tables** for routing/folder structure with increasing detail: summary, semi-detailed, and advanced.
- Include explanations for routing and components below the tables.
- Include a **UI Preview section** with screenshots grouped by Desktop, Laptop, Mobile. Sort images by their numeric suffix.
- Be **ready to paste directly** into a markdown previewer with no extra modification.
- Contain no redundant explanations or system-generated text outside the markdown block.

Make sure this `README.md` looks visually appealing, easy to read, and suitable for developers on GitHub or other platforms. Output strictly in one markdown code block.
]]
	)

	-- File tree structure (using tree command)
	vim.cmd("silent !tree -a -I 'node_modules|.git|dist|.cache' -L 4 > /tmp/project_structure.txt")
	local tree = read_file("/tmp/project_structure.txt")
	table.insert(output, "\n## 📁 File Structure\n```bash\n" .. tree .. "\n```")

	-- package.json content
	local pkg = read_file(project_root .. "/package.json")
	table.insert(output, "\n## 📦 package.json\n```json\n" .. pkg .. "\n```")

	-- Routes code snippets
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

	-- Existing README.md content
	local readme = read_file(project_root .. "/README.md")
	table.insert(output, "\n## 📄 Existing README\n```md\n" .. readme .. "\n```")

	-- Insert dynamic routing tables instructions (force LLM to generate 3 routing tables)
	table.insert(
		output,
		[[
## 🗺️ Routing & Folder Structure

### 1️⃣ Routes Summary Table (Quick Overview)

| Route Path | Purpose              | Auth Required | Notes              |
|------------|----------------------|---------------|--------------------|
| *Dynamically generate this table based on your project routes and structure.* | | | |

### 2️⃣ Routes Semi-Detailed Table (Add Components & HTTP Methods)

| Route Path | HTTP Method | Purpose           | UI Component(s)           | Auth Required |
|------------|-------------|-------------------|---------------------------|---------------|
| *Dynamically generate this table with more detail including HTTP methods and components.* | | | | |

### 3️⃣ Folder & Component Structure Table (Advanced Detail)

| Folder / File Path             | Purpose / Role                   | UI Features or Related Components         | Notes                          |
|-------------------------------|---------------------------------|-------------------------------------------|-------------------------------|
| *Generate an advanced detailed table describing folder structure, components, and UI features.* | | | |


### Routing & Components Explanation

Provide clear explanations for the routing conventions, protected vs public routes, and UI component responsibilities below the tables.
]]
	)

	-- Append the dynamic UI preview section
	table.insert(output, build_preview_section())

	-- Final output concatenation
	local final = table.concat(output, "\n\n")

	-- Save to file
	local out_path = project_root .. "/readmeGenerateFull.md"
	local f = io.open(out_path, "w")
	if f then
		f:write(final)
		f:close()
		vim.notify(
			"✅ README prompt with dynamic tables + preview saved to readmeGenerateFull.md",
			vim.log.levels.INFO
		)
	end

	-- Copy to clipboard
	vim.fn.setreg("+", final)
	vim.notify("📋 Copied README prompt with dynamic tables + preview to clipboard", vim.log.levels.INFO)

	-- Open in vertical split
	vim.cmd("vsplit " .. out_path)
end

-- 🔑 Keybinding: <leader>yr
vim.keymap.set("n", "<leader>yr", generate_readme_prompt_full, {
	desc = "📄 Generate README prompt with dynamic detailed routing tables + preview",
})
--p: ╰───────────── Block End ─────────────╯
