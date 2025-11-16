--w: (start)╭────────────  git push 1 LOC allowed ────────────╮
-- git push with 1 LOC allowed
vim.keymap.set("n", "<leader>gh", function()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	Intelligent_git_push(git_root, 1) -- Pass 1 as min_loc
end, { desc = "1 LOC allowed Manual intelligent Git push" })
--
--w: (end)  ╰────────────  git push 1 LOC allowed ────────────╯
