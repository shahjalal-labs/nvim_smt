local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local filetypes = {
	"javascriptreact",
	"typescriptreact",
}

local react_component = s("b", {
	t({ "const " }),
	f(function()
		return vim.fn.expand("%:t:r")
	end, {}),
	t(" = () => {"),
	t({ "  return (", "    <div>", "      " }),
	i(1, ""),
	t({ "", "    </div>", "  );", "};", "", "export default " }),
	f(function()
		return vim.fn.expand("%:t:r")
	end, {}),
	t(";"),
})

local arrow_component = s("a", {
	t({ "const " }),
	f(function()
		return vim.fn.expand("%:t:r")
	end, {}),
	t({ " = () => {", "  return (", "    <>" }),
	i(1, ""),
	t({ "", "    </>", "  );", "};", "", "export default " }),
	f(function()
		return vim.fn.expand("%:t:r")
	end, {}),
	t(";"),
})

return { react_component, arrow_component }
