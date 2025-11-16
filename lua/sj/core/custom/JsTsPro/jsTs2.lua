-- Define function globally (for diagnostics to detect usage)

--w: (start)╭──────────── navigate /src/console/log.json  ────────────╮
function OpenLogJson()
	local log_path = vim.fn.getcwd() .. "/src/console/log.json"
	vim.cmd("edit " .. log_path)
end

vim.api.nvim_set_keymap("n", "<leader>jl", ":lua OpenLogJson()<CR>", { noremap = true, silent = true })

--w: (end)  ╰──────────── navigate /src/console/log.json  ────────────╯
--

--
--w: (start)╭──────────── navigate /src/console/error.json  ────────────╮
function OpenErrorJson()
	local log_path = vim.fn.getcwd() .. "/src/console/error.json"
	vim.cmd("edit " .. log_path)
end

vim.api.nvim_set_keymap("n", "<leader>jq", ":lua OpenErrorJson()<CR>", { noremap = true, silent = true })
--
--w: (end)  ╰──────────── navigate /src/console/error.json  ────────────╯
