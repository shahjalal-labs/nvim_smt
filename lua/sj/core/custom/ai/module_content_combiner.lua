--w: (start)╭────────────   ────────────╮
--p: copy all content for a folder to clipboard for llm context feeding
vim.keymap.set("n", "<leader>g,", function()
	local module_path = vim.fn.system("wl-paste"):gsub("%s+$", "")
	if vim.fn.isdirectory(module_path) == 0 then
		vim.notify("❌ Not a valid folder: " .. module_path, vim.log.levels.ERROR)
		return
	end

	local module_name = module_path:match("([^/]+)$") or "Unknown"
	local output_file = module_path .. "/" .. module_name .. "FullContent.md"
	local project_root = vim.fn.getcwd()

	-- Get project tree
	local cwd_tree = vim.fn.systemlist(
		"tree -I '.git|node_modules|dist|build|coverage|assets' '" .. project_root .. "'"
	) or {}

	-- Get module tree
	local module_tree = vim.fn.systemlist("tree '" .. module_path .. "'") or {}

	-- Read schema.prisma
	local schema_content = {}
	local schema_file = project_root .. "/prisma/schema.prisma"
	local schema_ok, schema_lines = pcall(vim.fn.readfile, schema_file)
	if schema_ok and schema_lines then
		schema_content = schema_lines
	end

	-- Read package.json
	local package_content = {}
	local package_file = project_root .. "/package.json"
	local package_ok, package_lines = pcall(vim.fn.readfile, package_file)
	if package_ok and package_lines then
		package_content = package_lines
	end

	-- Build markdown content
	local content = {
		"# " .. module_name .. "FullContent.md",
		"",
		"## 🌲 Full Project Structure",
		"",
		"```bash",
	}

	-- Add project tree
	for _, line in ipairs(cwd_tree) do
		table.insert(content, line)
	end
	table.insert(content, "```")
	table.insert(content, "")

	-- Add module tree
	table.insert(content, "## 📁 " .. module_name .. " Module Tree")
	table.insert(content, "")
	table.insert(content, "```bash")
	for _, line in ipairs(module_tree) do
		table.insert(content, line)
	end
	table.insert(content, "```")
	table.insert(content, "")

	-- Add schema.prisma
	table.insert(content, "## 📋 schema.prisma")
	table.insert(content, "")
	table.insert(content, "```prisma")
	for _, line in ipairs(schema_content) do
		table.insert(content, line)
	end
	table.insert(content, "```")
	table.insert(content, "")

	-- Add package.json
	table.insert(content, "## 📦 package.json")
	table.insert(content, "")
	table.insert(content, "```json")
	for _, line in ipairs(package_content) do
		table.insert(content, line)
	end
	table.insert(content, "```")
	table.insert(content, "")

	-- Add all module files
	local file_handle = io.popen(
		'find "'
			.. module_path
			.. '" -type f -name "*.ts" -o -name "*.js" -o -name "*.json" -o -name "*.hurl" -o -name "*.md"'
	)
	if file_handle then
		local filelist = file_handle:read("*a") or ""
		file_handle:close()

		for _, file in ipairs(vim.split(filelist, "\n", { trimempty = true })) do
			local rel_path = file:sub(#module_path + 2)
			local ext = file:match("^.+(%..+)$") or ""
			local lang = ext:gsub("%.", "")
				:gsub("jsx", "javascript")
				:gsub("tsx", "typescript")
				:gsub("js", "javascript")
				:gsub("hurl", "bash")
				:gsub("md", "markdown")

			local lines = vim.fn.readfile(file)
			if lines and #lines > 0 then
				-- Add emoji based on file type
				local emoji = "📄"
				if ext == ".ts" or ext == ".js" then
					if string.find(rel_path, "controller") then
						emoji = "🎮"
					elseif string.find(rel_path, "service") then
						emoji = "🛠️"
					elseif string.find(rel_path, "route") then
						emoji = "🔧"
					elseif string.find(rel_path, "validation") then
						emoji = "📝"
					elseif string.find(rel_path, "constant") then
						emoji = "⚙️"
					else
						emoji = "📄"
					end
				elseif ext == ".json" then
					emoji = "📦"
				elseif ext == ".hurl" then
					emoji = "🧪"
				elseif ext == ".md" then
					emoji = "📖"
				end

				table.insert(content, "## " .. emoji .. " " .. rel_path)
				table.insert(content, "")
				table.insert(content, "```" .. lang)
				for _, line in ipairs(lines) do
					table.insert(content, line)
				end
				table.insert(content, "```")
				table.insert(content, "")
			end
		end
	end

	local content_str = table.concat(content, "\n")

	-- Write to file
	local ok_file, file_obj = pcall(io.open, output_file, "w")
	if not ok_file or not file_obj then
		vim.notify("❌ Failed to write output file: " .. output_file, vim.log.levels.ERROR)
		return
	end
	file_obj:write(content_str)
	file_obj:close()

	-- Copy to clipboard
	local tmp_clip = "/tmp/__full_content.md"
	local tmp_handle = io.open(tmp_clip, "w")
	if tmp_handle then
		tmp_handle:write(content_str)
		tmp_handle:close()
		vim.fn.system("wl-copy < " .. tmp_clip)
	else
		vim.notify("⚠️ Could not copy to clipboard", vim.log.levels.WARN)
	end

	-- Open the file in Neovim
	vim.cmd("e " .. output_file)

	vim.notify("✅ Generated: " .. output_file .. " and copied to clipboard! 🚀", vim.log.levels.INFO)
end, { desc = "Generate full module content file and copy to clipboard" })

--w: (end)  ╰────────────   ────────────╯
