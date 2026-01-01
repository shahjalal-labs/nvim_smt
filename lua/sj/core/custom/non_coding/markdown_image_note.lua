
vim.keymap.set('n', '<leader>mm', function()
    -- Get current file path and directory
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path == "" then
        print("No file detected!")
        return
    end

    local dir = vim.fn.fnamemodify(file_path, ":h")       -- folder path
    local base = vim.fn.fnamemodify(file_path, ":t:r")    -- filename without extension
    local img_file = string.format("%s/%s.png", dir, base) -- full path for image

    -- Save clipboard image (Linux example using xclip)
    local save_cmd = string.format("xclip -selection clipboard -t image/png -o > '%s'", img_file)
    local result = os.execute(save_cmd)
    if result ~= 0 then
        print("Failed to save image from clipboard")
        return
    end

    -- Insert markdown image link at cursor
    local markdown_link = string.format("![%s](%s.png)", base, base)
    vim.api.nvim_put({markdown_link}, "c", true, true)

    print("Saved clipboard image as " .. img_file)
end, { noremap = true, silent = true })
