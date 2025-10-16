--p: ╭──────────── Block Start ────────────╮
--t: readme generate prompt maker with dynamic recursive UI preview (case-insensitive device folders) and safe markdown image links
-- 🔥 Generate AI-Ready README Prompt + UI Preview Section with recursive image scan, flatten, sorted, safe path links

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

-- Helper: Title from filename (e.g., homePage1.png → Home Page)
local function extract_title(filename)
	local name = filename:match("(.+)%d+%..+$") or filename
	name = name:gsub("([a-z])([A-Z])", "%1 %2") -- camelCase split
	name = name:gsub("[-_]", " ") -- kebab_case or snake_case
	name = name:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
	name = name:sub(1, 1):upper() .. name:sub(2)
	return name
end

-- Helper: Search for folder name case-insensitively in base directory, return real folder name or nil
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

-- Helper: Recursively find all image files under a path
local function find_all_images(path)
	local images = {}
	-- find files matching typical image extensions, print relative filename only
	local cmd = 'find "'
		.. path
		.. '" -type f \\( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \\) -printf "%P\n" 2>/dev/null'
	local handle = io.popen(cmd)
	if handle then
		for file in handle:lines() do
			-- extract numeric suffix just before extension for sorting
			local num = file:match("(%d+)%.[^.]+$") -- e.g. "HomePage1.png" → 1
			if num then
				table.insert(images, { file = file, num = tonumber(num) })
			end
		end
		handle:close()
	end
	-- sort by numeric suffix ascending
	table.sort(images, function(a, b)
		return a.num < b.num
	end)
	return images
end

-- Build UI preview markdown section (flatten all images per device folder, sorted by number, safe markdown links)
local function build_preview_section()
	local preview = { "\n## 🖼️ UI Preview Section\n" }
	local base_preview_path = project_root .. "/src/assets/images/preview"
	local devices = { "Desktop", "Laptop", "Mobile" }

	local device_labels = {
		Desktop = "🖥️ Desktop View",
		Laptop = "💻 Laptop View",
		Mobile = "📱 Mobile View",
	}

	for _, device in ipairs(devices) do
		local actual_device_folder = find_folder_case_insensitive(base_preview_path, device)
		local device_label = device_labels[device] or device
		table.insert(preview, "### " .. device_label .. "\n")

		if not actual_device_folder then
			table.insert(preview, "_No previews found for " .. device_label .. "._\n")
		else
			local device_path = base_preview_path .. "/" .. actual_device_folder
			local images = find_all_images(device_path)

			if #images == 0 then
				table.insert(preview, "_No images found under " .. device_label .. "._\n")
			else
				for _, img in ipairs(images) do
					local title = extract_title(img.file)
					-- Build safe markdown path: wrap in < > to handle spaces and special chars
					local rel_path = string.format("src/assets/images/preview/%s/%s", actual_device_folder, img.file)
					table.insert(preview, string.format("**%s**  \n![](<%s>)\n", title, rel_path))
				end
			end
		end
	end

	return table.concat(preview, "\n")
end

-- Main function to generate README prompt with UI preview
local function generate_readme_prompt_with_preview()
	local output = {}

	-- AI Prompt instructions block
	table.insert(
		output,
		[[
Generate a professional, modern, and production-ready `README.md` file based on my project. Your entire output **must be enclosed within a single markdown code block** using triple backticks and `markdown` as the language. Absolutely **no text should be outside** the code block. The structure, formatting, and content should follow **industry best practices** for open-source projects, with clearly separated sections (e.g., Features, Tech Stack, Installation, Folder Structure, License, etc.).

The markdown must:
- Your entire Output must be inside one **single** markdown code block using triple backticks (```) and `markdown` as the language
- Use clear section headers (`##`) and subheaders (`###`) consistently
- Include emoji icons in section titles for modern visual appeal
- Apply bullet lists, tables, and code fences (` ``` `) for commands and code
- Be **ready to paste directly** into a markdown previewer with no extra modification
- Contain no redundant explanations or system-generated text outside the markdown block

Make sure this `README.md` looks visually appealing, easy to read, and suitable for developers on GitHub or other platforms. Output strictly in one markdown code block.
]]
	)

	-- File tree structure snapshot
	vim.cmd("silent !tree -a -I 'node_modules|.git|dist|.cache' -L 4 > /tmp/project_structure.txt")
	local tree = read_file("/tmp/project_structure.txt")
	table.insert(output, "\n## 📁 File Structure\n```bash\n" .. tree .. "\n```")

	-- package.json contents
	local pkg = read_file(project_root .. "/package.json")
	table.insert(output, "\n## 📦 package.json\n```json\n" .. pkg .. "\n```")

	-- Route files contents
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

	-- Existing README contents
	local readme = read_file(project_root .. "/README.md")
	table.insert(output, "\n## 📄 Existing README\n```md\n" .. readme .. "\n```")

	-- Add UI Preview Section markdown
	table.insert(output, build_preview_section())

	-- Combine all output parts
	local final = table.concat(output, "\n\n")

	-- Wrap everything in one markdown code block for LLM prompt
	local wrapped_output = "```markdown\n" .. final .. "\n```"

	-- Write output to file
	local out_path = project_root .. "/readmeGenerate.md"
	local f = io.open(out_path, "w")
	if f then
		f:write(wrapped_output)
		f:close()
		vim.notify("✅ README prompt + preview saved to readmeGenerate.md", vim.log.levels.INFO)
	end

	-- Copy output to clipboard
	vim.fn.setreg("+", wrapped_output)
	vim.notify("📋 Copied README prompt with preview to clipboard", vim.log.levels.INFO)

	-- Open the generated file in vertical split
	vim.cmd("vsplit " .. out_path)
end

-- Keybinding for easy trigger
vim.keymap.set("n", "<leader>yp", generate_readme_prompt_with_preview, {
	desc = "📄 Generate README prompt with preview section (recursive image scan, safe markdown links)",
})
--p: ╰───────────── Block End ─────────────╯
--
--p: ╭──────────── Block Start ────────────╮
--append screenshots directly to README.md
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
--p: ╰───────────── Block End ─────────────╯
