--[[ vim.keymap.set("n", "<leader>ge", function()
	local module_path = vim.fn.system("wl-paste"):gsub("%s+$", "")
	if vim.fn.isdirectory(module_path) == 0 then
		vim.notify("❌ Not a valid folder: " .. module_path, vim.log.levels.ERROR)
		return
	end

	local module_name = module_path:match("([^/]+)$") or "Unknown"
	local prompt_file = module_path .. "/refractor" .. module_name:gsub("^%l", string.upper) .. "Prompt.md"

	local tree_cmd = "tree -I '.git|node_modules' '" .. module_path .. "'"
	local tree_output = vim.fn.systemlist(tree_cmd) or {}

	local header = {
		"You are a **senior full-stack developer**.",
		"",
		"## 📌 Task",
		"",
		"You are given a real-world code module located at:",
		"",
		"```",
		module_path,
		"```",
		"",
		"Refactor the entire codebase **without modifying any UI or changing behavior**. Instead, improve it using:",
		"",
		"- ✅ Clear separation of concerns",
		"- ✅ Consistent, semantic naming conventions",
		"- ✅ Modular architecture (hooks, services, utils, components)",
		"- ✅ Scalable file/folder structure",
		"- ✅ Industry-standard project layout and architecture",
		"- ✅ Readable, testable, production-grade code",
		"- ✅ 100% behavior and API compatibility",
		"",
		"👉 Output the refactored code to a new folder: `" .. module_name .. "_refactored`",
		"",
		"Also return a `.sh` script that will:",
		"- Create that folder",
		"- Write all refactored files",
		"- Run `git add` and `git commit` with message: `refactor: added improved " .. module_name .. " version`",
		"",
		"---",
		"",
		"## 🌲 Full Project Structure (for context)",
		"",
		"```bash",
	}

	vim.list_extend(header, tree_output)
	table.insert(header, "```")
	table.insert(header, "")
	table.insert(header, "## 📁 Module Files & Contents")
	table.insert(header, "")

	local file_handle = io.popen('find "' .. module_path .. '" -type f')
	if not file_handle then
		vim.notify("❌ Failed to read files from module folder", vim.log.levels.ERROR)
		return
	end

	local filelist = file_handle:read("*a") or ""
	file_handle:close()

	local prompt = vim.deepcopy(header)

	for _, file in ipairs(vim.split(filelist, "\n", { trimempty = true })) do
		local rel_path = file:sub(#module_path + 2)
		local ext = file:match("^.+(%..+)$") or ""
		local lang = ext:gsub("%.", ""):gsub("jsx", "javascript"):gsub("tsx", "typescript"):gsub("js", "javascript")

		local lines = vim.fn.readfile(file)
		if lines and #lines > 0 then
			table.insert(prompt, "### `" .. rel_path .. "`")
			table.insert(prompt, "```" .. lang)
			vim.list_extend(prompt, lines)
			table.insert(prompt, "```")
			table.insert(prompt, "")
		end
	end

	local prompt_str = table.concat(prompt, "\n")

	local ok_file, file_obj = pcall(io.open, prompt_file, "w")
	if not ok_file or not file_obj then
		vim.notify("❌ Failed to write prompt file: " .. prompt_file, vim.log.levels.ERROR)
		return
	end

	file_obj:write(prompt_str)
	file_obj:close()

	-- Copy to clipboard using wl-copy safely
	local tmp_clip = "/tmp/__refactor_prompt.md"
	local tmp_handle = io.open(tmp_clip, "w")
	if tmp_handle then
		tmp_handle:write(prompt_str)
		tmp_handle:close()
		vim.fn.system("wl-copy < " .. tmp_clip)
	else
		vim.notify("⚠️ Could not copy to clipboard", vim.log.levels.WARN)
	end

	vim.notify("✅ Refactor prompt saved to:\n" .. prompt_file .. "\n📋 Copied to clipboard", vim.log.levels.INFO)
end, { desc = "Generate refactor prompt from clipboard path" }) ]]

-- updated version

--- src/assets
---

vim.keymap.set("n", "<leader>ge", function()
	local module_path = vim.fn.system("wl-paste"):gsub("%s+$", "")
	if vim.fn.isdirectory(module_path) == 0 then
		vim.notify("❌ Not a valid folder: " .. module_path, vim.log.levels.ERROR)
		return
	end

	local module_name = module_path:match("([^/]+)$") or "Unknown"
	local prompt_file = module_path .. "/refractor" .. module_name:gsub("^%l", string.upper) .. "Prompt.md"

	-- Project CWD tree
	local project_root = vim.fn.getcwd()
	-- local cwd_tree = vim.fn.systemlist("tree -I '.git|node_modules|dist|src/assets' '" .. project_root .. "'") or {}
	local cwd_tree = vim.fn.systemlist(
		"tree -I '.git|node_modules|dist|build|coverage|assets' '" .. project_root .. "'"
	) or {}

	-- Module folder tree
	local module_tree = vim.fn.systemlist("tree -I '.git|node_modules' '" .. module_path .. "'") or {}

	-- Base prompt instructions
	local header = {
		"You are a **senior full-stack developer**.",
		"",
		"## 📌 Task",
		"",
		"You are given a real-world code module located at:",
		"",
		"```",
		module_path,
		"```",
		"",
		"Refactor the entire codebase **without modifying any UI or changing behavior**. Instead, improve it using:",
		"",
		"- ✅ Clear separation of concerns",
		"- ✅ Consistent, semantic naming conventions",
		"- ✅ Modular architecture (hooks, services, utils, components)",
		"- ✅ Scalable file/folder structure",
		"- ✅ Industry-standard project layout and architecture",
		"- ✅ Readable, testable, production-grade code",
		"- ✅ 100% behavior and API compatibility",
		"",
		"👉 Output the refactored code to a new folder: `" .. module_name .. "_refactored`",
		"",
		"Also return a `.sh` script that will:",
		"- Create that folder",
		"- Write all refactored files",
		"- Run `git add` and `git commit` with message: `refactor: added improved " .. module_name .. " version`",
		"",
		"---",
		"",
		"## 🌲 Full Project Structure (cwd)",
		"",
		"```bash",
	}

	vim.list_extend(header, cwd_tree)
	table.insert(header, "```")
	table.insert(header, "")
	table.insert(header, "## 📁 Target Module Tree (" .. module_name .. ")")
	table.insert(header, "")
	table.insert(header, "```bash")
	vim.list_extend(header, module_tree)
	table.insert(header, "```")
	table.insert(header, "")
	table.insert(header, "## 📄 Module Files & Contents")
	table.insert(header, "")

	-- Collect all files
	local file_handle = io.popen('find "' .. module_path .. '" -type f')
	if not file_handle then
		vim.notify("❌ Failed to read files from module folder", vim.log.levels.ERROR)
		return
	end

	local filelist = file_handle:read("*a") or ""
	file_handle:close()

	local prompt = vim.deepcopy(header)

	for _, file in ipairs(vim.split(filelist, "\n", { trimempty = true })) do
		local rel_path = file:sub(#module_path + 2)
		local ext = file:match("^.+(%..+)$") or ""
		local lang = ext:gsub("%.", ""):gsub("jsx", "javascript"):gsub("tsx", "typescript"):gsub("js", "javascript")

		local lines = vim.fn.readfile(file)
		if lines and #lines > 0 then
			table.insert(prompt, "### `" .. rel_path .. "`")
			table.insert(prompt, "```" .. lang)
			vim.list_extend(prompt, lines)
			table.insert(prompt, "```")
			table.insert(prompt, "")
		end
	end

	local prompt_str = table.concat(prompt, "\n")

	local ok_file, file_obj = pcall(io.open, prompt_file, "w")
	if not ok_file or not file_obj then
		vim.notify("❌ Failed to write prompt file: " .. prompt_file, vim.log.levels.ERROR)
		return
	end

	file_obj:write(prompt_str)
	file_obj:close()

	-- Copy to clipboard using wl-copy
	local tmp_clip = "/tmp/__refactor_prompt.md"
	local tmp_handle = io.open(tmp_clip, "w")
	if tmp_handle then
		tmp_handle:write(prompt_str)
		tmp_handle:close()
		vim.fn.system("wl-copy < " .. tmp_clip)
	else
		vim.notify("⚠️ Could not copy to clipboard", vim.log.levels.WARN)
	end

	-- Open prompt file in Neovim right after creation
	vim.cmd("e " .. prompt_file)

	vim.notify("✅ Prompt saved to: " .. prompt_file .. " and copied to clipboard", vim.log.levels.INFO)
end, { desc = "Generate LLM refactor prompt from clipboard module path" })
