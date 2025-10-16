-- vim.api.nvim_set_keymap("i", "j$", "<C-o>$<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "j$", "<C-o>$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jdd", "<C-o>dd", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jI", "<C-o>I", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jA", "<C-o>A", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jO", "<C-o>O", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jcc", "<ESC>cc", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<C-s>", "<ESC>cc", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jc$", "<C-o>c$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jciw", "<C-o>ciw", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jdiw", "<C-o>diw", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jcw", "<C-o>cw", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jdw", "<C-o>dw", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "@c", "<C-o>@c", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "@d", "<C-o>@d", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "@x", "<C-o>@x", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "yy", "<C-o>yy", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "yw", "<C-o>yw", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "yiw", "<C-o>yiw", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "jp", "<C-r>+", { noremap = true, silent = true })
-- Map Ctrl+e to scroll down in Insert Mode
vim.keymap.set("i", "<C-e>", "<C-o><C-e>", { noremap = true, silent = true })

-- Map Ctrl+y to scroll up in Insert Mode
vim.keymap.set("i", "<C-y>", "<C-o><C-y>", { noremap = true, silent = true })

-- Scroll up with 'w' in normal mode
-- vim.api.nvim_set_keymap("n", "w", "<C-y>", { noremap = true, silent = true })
-- Scroll down with 'e' in normal mode
-- vim.api.nvim_set_keymap("n", "e", "<C-e>", { noremap = true, silent = true })
