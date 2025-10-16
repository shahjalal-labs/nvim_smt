local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Type definition snippet
	s("ttype", {
		t("type T"),
		i(1, "Name"),
		t(" = {"),
		i(0),
		t("}"),
	}),

	-- Interface snippet
	s("u", {
		t("interface I"),
		i(1, "Name"),
		t({ " {", "    " }),
		i(0),
		t({ "", "}" }),
	}),
}
