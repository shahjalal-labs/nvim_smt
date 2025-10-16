local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("h", {
		t({
			"<!doctype html>",
			'<html lang="en">',
			"  <head>",
			'    <meta charset="UTF-8" />',
			'    <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
			"    <title>",
		}),
		i(1),
		t({ "</title>", '    <link rel="stylesheet" href="' }),
		i(2),
		t({ '" />', "  </head>", "  <body>" }),
		i(3),
		t({ "  </body>", "</html>" }),
	}),
}
