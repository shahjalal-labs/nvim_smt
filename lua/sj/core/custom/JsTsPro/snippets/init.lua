local ls = require("luasnip")

local function safe_load(ft, path)
	local ok, snippets = pcall(require, path)
	if ok then
		ls.add_snippets(ft, snippets)
	else
		vim.notify("Failed to load snippets: " .. path, vim.log.levels.WARN)
	end
end

-- load snippets

local filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

for _, ft in ipairs(filetypes) do
	safe_load(ft, "sj.core.custom.JsTsPro.snippets.javascript")
end

safe_load("html", "sj.core.custom.JsTsPro.snippets.html")
