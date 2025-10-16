local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	-- Arrow function snippet for JavaScript
	s(
		"af",
		fmt(
			[[
const {} = {}({}) => {{
  {}
}};
]],
			{
				i(1, ""),
				c(2, { t(""), t("async ") }),
				i(3, "params"),
				i(4, ""),
			}
		)
	),

	-- Page snippet for JavaScript (from your large file)
	s("d", {
		t("const "),
		f(function(_, snip)
			local dir = snip.env.TM_DIRECTORY
			local parent = dir:match(".*/([^/]+)/%[.-%]$")
			local function pascal_case(str)
				return (str:gsub("(%a)(%w*)", function(a, b)
					return a:upper() .. b:lower()
				end))
			end
			return parent and pascal_case(parent) .. "Details" or "ComponentDetails"
		end, {}),
		t(" = async ({ params }) => {"),
		t({ "", "  const p = await params;" }),
		t({ "", "  console.log(p." }),
		f(function(_, snip)
			local dir = snip.env.TM_DIRECTORY
			local param = dir:match(".*/%[(.-)%]$")
			return param or "id"
		end, {}),
		t({ ', "dynamicId in params", 3);', "", "", "  return (", "    <div>", "      " }),
		f(function(_, snip)
			local dir = snip.env.TM_DIRECTORY
			local parent = dir:match(".*/([^/]+)/%[.-%]$")
			local function pascal_case(str)
				return (str:gsub("(%a)(%w*)", function(a, b)
					return a:upper() .. b:lower()
				end))
			end
			return parent and pascal_case(parent) .. "Details" or "ComponentDetails"
		end, {}),
		i(0),
		t({ "</h2>", "    </div>", "  );", "};", "", "export default " }),
		f(function(_, snip)
			local dir = snip.env.TM_DIRECTORY
			local parent = dir:match(".*/([^/]+)/%[.-%]$")
			local function pascal_case(str)
				return (str:gsub("(%a)(%w*)", function(a, b)
					return a:upper() .. b:lower()
				end))
			end
			return parent and pascal_case(parent) .. "Details" or "ComponentDetails"
		end, {}),
		t(";"),
	}),
}
