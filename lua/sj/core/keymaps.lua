-- set leader key to space
-- vim.g.mapleader = ";"
-- -- Unmap 'f' in normal mode to avoid conflict
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness
-- Set an extremely short timeoutlen (50 milliseconds)
vim.o.timeoutlen = 50
-- General Keymaps -------------------

-- clear search highlights
keymap.set("n", "<leader>cc", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "t", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "T", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- -- Increase/decrease split width with Alt+h and Alt+l
vim.api.nvim_set_keymap("n", "<A-l>", ":vertical resize -2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-h>", ":vertical resize +2<CR>", { noremap = true, silent = true })
--
-- -- Increase/decrease split height with Alt+j and Alt+k
vim.api.nvim_set_keymap("n", "<Down>", ":resize -2<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Up>", ":resize +2<CR>", { noremap = true, silent = true })
--
-- use jk to exit insert mode
-- keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jk" })

-- global search with alt-o vs code ctrl-shift-f
-- vim.api.nvim_set_keymap("n", "<A-o>", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-o>", ":Telescope live_grep search_dirs={'src'}<CR>", { noremap = true, silent = true })

-- Map Alt+i to :wqa! in normal mode
vim.api.nvim_set_keymap("n", "<M-i>", ":qa!<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<M-i>", "<ESC>:qa!<CR>", { noremap = true, silent = true })

--for formatting indent like vs code
vim.api.nvim_set_keymap(
	"n",
	"<leader>fy",
	":lua vim.lsp.buf.format({ async = true })<CR>",
	{ noremap = true, silent = true }
)
--w:Remap Shift+F3 to insert ':'
vim.api.nvim_set_keymap("i", "<S-F3>", ":", { noremap = true, silent = true })

--p: Remap Ctrl+F3 to insert ';'
vim.api.nvim_set_keymap("i", "<C-F3>", ";", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-F3>", ":", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<M-u>", ":e <C-R>+<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "gj", "G$", { noremap = true, silent = true })
vim.keymap.set("n", "gg", "gg0", { noremap = true, silent = true })
vim.keymap.set("x", "gj", "G$", { noremap = true, silent = true })
vim.keymap.set("x", "gg", "gg0", { noremap = true, silent = true })
vim.keymap.set("n", "<M-j>", "10j", { noremap = true, silent = true })
vim.keymap.set("n", "<M-k>", "10k", { noremap = true, silent = true })

vim.keymap.set("n", "<Space>jk", "<C-^>", { silent = true, desc = "Go to last visited file" })
vim.keymap.set("i", "ii", "<ESC><C-^>", { silent = true, desc = "Go to last visited file" })
--p: for better navigation in boxes record
vim.keymap.set("i", "<C-g>", "<ESC>jhhi", { silent = true, desc = "Go to last visited file" })

vim.keymap.set({ "n", "x", "o" }, "<C-f3>", "<C-^>", {
	silent = true,
	desc = "Go to last visited file",
})

--w: use jk to exit insert mode
keymap.set("i", "kk", "<ESC>", { desc = "Exit insert mode with jk" })
