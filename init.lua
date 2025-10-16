require("sj.core")
require("sj.lazy")

--
--
--
-- w: ╭──────────── Block Start ────────────╮
-- tabline for showing foldername/fileRelativePath
vim.opt.showtabline = 2

-- Custom tabline function
vim.o.tabline = "%!v:lua.MyTabline()"

-- Expose function globally
_G.MyTabline = function()
	local s = ""

	-- Create custom night-themed highlights if not defined
	vim.cmd("highlight TabLineNightActive guibg=#27546A guifg=#cdd6f4") -- dark background, light text
	vim.cmd("highlight TabLineNightInactive guibg=#11111b guifg=#7f849c") -- darker background, dim text

	local hl_active = "%#TabLineNightActive#"
	local hl_inactive = "%#TabLineNightInactive#"

	local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t") -- root folder name

	-- Loop through all tabs
	for i = 1, vim.fn.tabpagenr("$") do
		local buflist = vim.fn.tabpagebuflist(i)
		local winnr = vim.fn.tabpagewinnr(i)
		local bufname = vim.fn.bufname(buflist[winnr])
		local filename = vim.fn.fnamemodify(bufname, ":t")
		if filename == "" then
			filename = "[No Name]"
		end

		if i == vim.fn.tabpagenr() then
			-- Active tab: show rootFolderName/relativePath
			local relpath = vim.fn.fnamemodify(bufname, ":~:.")
			if relpath == "" then
				relpath = "[No Name]"
			end
			s = s .. hl_active .. " " .. cwd .. "/" .. relpath .. " "
		else
			-- Inactive tabs: just filename
			s = s .. hl_inactive .. " " .. filename .. " "
		end
	end

	return s
end

-- Toggle function
local function toggle_tabline()
	if vim.o.showtabline == 0 then
		vim.o.showtabline = 2 -- show always
		print("Tabline: ON")
	else
		vim.o.showtabline = 0 -- hide always
		print("Tabline: OFF")
	end
end

-- Map to <leader>tt
vim.keymap.set("n", "<leader>tt", toggle_tabline, { noremap = true, silent = true })

--w: ╰───────────── Block End ─────────────╯
