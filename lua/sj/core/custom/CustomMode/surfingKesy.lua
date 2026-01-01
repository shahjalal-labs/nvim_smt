```lua
-- Add to your surfingKesy.lua
-- Ensure flash is loaded; if not, require it here
local flash = require("flash")

-- Custom yank word with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yw", function()
  flash.jump({
    pattern = "\\<\\w\\+\\>", -- Match words
    search = { mode = "search", max_length = 0 }, -- Hint all matches
    action = function(match, state)
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      vim.cmd("normal! yiw") -- Yank inner word
      state:restore() -- Return to original position
    end,
    jump = { pos = "start" }, -- Jump to start for yank
  })
end, { desc = "Yank word with hints" })

-- Custom yank line with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yl", function()
  flash.jump({
    pattern = "^",
    action = function(match, state)
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      vim.cmd("normal! yy") -- Yank entire line
      state:restore()
    end,
  })
end, { desc = "Yank line with hints" })

-- Custom yank block/paragraph with hints (basic, non-Tree-sitter)
vim.keymap.set({ "n", "x", "o" }, "<leader>yb", function()
  flash.jump({
    pattern = ".", -- General pattern to hint visible positions
    search = { mode = "search" },
    action = function(match, state)
      vim.api.nvim_win_set_cursor(match.win, match.pos)
      vim.cmd("normal! yap") -- Yank around paragraph/block
      state:restore()
    end,
  })
end, { desc = "Yank block with hints" })

-- Custom yank Tree-sitter block with hints
vim.keymap.set({ "n", "x", "o" }, "<leader>yt", function()
  flash.treesitter_search({
    remote_op = { restore = true, motion = true },
    action = function(match, state)
      -- Yank the Tree-sitter node
      vim.cmd("normal! yit") -- Yank inner Tree-sitter node (adjust 'it' as needed)
      state:restore()
    end,
  })
end, { desc = "Yank Tree-sitter block with hints" })

-- Optional: Customize label colors (add to your highlight setup or here)
vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ff00ff", bold = true }) -- Base color
-- For type-specific colors, you can override in each jump config if needed, e.g.:
-- In yw: label = { rainbow = { enabled = true, shade = 1 } } for blue-ish
-- In yl: shade = 5 for green, etc.
```
