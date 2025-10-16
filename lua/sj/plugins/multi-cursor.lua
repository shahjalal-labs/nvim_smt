return {
	"brenton-leighton/multiple-cursors.nvim",
	version = "*",
	opts = {},
	keys = {
		-- Directional cursor add
		{ "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Add cursor and move down" },
		{ "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Add cursor and move up" },
		{ "<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "i", "x" }, desc = "Add cursor and move down" },
		{ "<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "i", "x" }, desc = "Add cursor and move up" },
		{ "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = { "n", "i" }, desc = "Add or remove cursor" },

		-- ⬅ Mnemonic group with <Leader>m
		{ "<Leader>ma", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "Add cursors to matches" }, -- a = add
		{ "<Leader>mv", "<Cmd>MultipleCursorsAddVisualArea<CR>", mode = { "x" }, desc = "Add cursors to visual lines" }, -- v = visual
		{ "<Leader>mu", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "x" }, desc = "Add cursor upward" }, -- u = up
		{ "<Leader>md", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "x" }, desc = "Add cursor downward" }, -- d = down
		{
			"<Leader>mj",
			"<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
			mode = { "n", "x" },
			desc = "Add cursor and jump next match",
		}, -- j = jump
		{ "<Leader>mn", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = { "n", "x" }, desc = "Jump to next match" }, -- n = next
		{ "<Leader>mp", "<Cmd>MultipleCursorsJumpPrevMatch<CR>", mode = { "n", "x" }, desc = "Jump to previous match" }, -- p = previous
		{ "<Leader>ml", "<Cmd>MultipleCursorsLock<CR>", mode = { "n", "x" }, desc = "Lock cursors" }, -- l = lock
	},
}
