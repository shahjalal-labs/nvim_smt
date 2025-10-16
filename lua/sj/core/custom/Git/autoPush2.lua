--p: git push  1 LOC allowed
vim.api.nvim_create_user_command("GitSmartPush", function()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	intelligentGitPushOneLocAvailable(git_root)
end, {})

-- keep this keymap for manual triggering
vim.keymap.set("n", "<leader>gh", function()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	intelligentGitPushOneLocAvailable(git_root)
end, { desc = "1 LOC allowed Manual intelligent Git push" })
