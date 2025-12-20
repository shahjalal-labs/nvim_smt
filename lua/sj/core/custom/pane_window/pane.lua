-- Neovim Smart Split Management with Lua

-- Create vertical split with leader pv
vim.api.nvim_set_keymap("n", "<Leader>pv", ":vsplit<CR>", { noremap = true, silent = true })

-- Create horizontal split with leader ph
vim.api.nvim_set_keymap("n", "<Leader>ph", ":split<CR>", { noremap = true, silent = true })

-- Swap split to the left with leader pu
vim.api.nvim_set_keymap("n", "<Leader>pu", ":wincmd H<CR>", { noremap = true, silent = true })

-- Swap split to the right with leader pi
vim.api.nvim_set_keymap("n", "<Leader>pi", ":wincmd L<CR>", { noremap = true, silent = true })
