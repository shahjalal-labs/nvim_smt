local function run_hurl_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local cur_line = cursor[1]
	local total = vim.api.nvim_buf_line_count(bufnr)

	local start_line = nil
	local end_line = nil

	-- Find block start (search upward)
	for i = cur_line, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
		if line:match("^#%s+") then
			start_line = i
			break
		end
	end

	if not start_line then
		vim.notify("No Hurl block start found", vim.log.levels.WARN)
		return
	end

	-- Find block end (next valid header)
	for i = start_line + 1, total do
		local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
		if line:match("^#%s+") then
			end_line = i - 1
			break
		end
	end

	-- If last block
	if not end_line then
		end_line = total
	end

	-- Select the block
	vim.cmd("normal! " .. start_line .. "GV" .. end_line .. "G")

	-- Run Hurl
	vim.cmd("HurlRunner")
end

vim.keymap.set("n", "<leader>th", run_hurl_block, {
	desc = "Run current Hurl block",
})

return {
	"jellydn/hurl.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Optional, for markdown rendering with render-markdown.nvim
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown" },
			},
			ft = { "markdown" },
		},
	},
	ft = "hurl",
	opts = {
		-- Show debugging info
		debug = false,
		-- Show notification on run
		show_notification = false,
		-- Show response in popup or split
		mode = "split",
		auto_close = false,
		-- Default formatter
		formatters = {
			json = { "jq" }, -- Make sure you have install jq in your system, e.g: brew install jq
			html = {
				"prettier", -- Make sure you have install prettier in your system, e.g: npm install -g prettier
				"--parser",
				"html",
			},
			xml = {
				"tidy", -- Make sure you have installed tidy in your system, e.g: brew install tidy-html5
				"-xml",
				"-i",
				"-q",
			},
		},
		-- Default mappings for the response popup or split views
		mappings = {
			close = "q", -- Close the response popup or split view
			next_panel = "<C-n>", -- Move to the next response popup window
			prev_panel = "<C-p>", -- Move to the previous response popup window
		},
	},
	keys = {
		-- Run API request
		{ "<leader>hh", "<cmd>HurlRunner<CR>", desc = "Run All requests" },
		{ "<leader>hl", "<cmd>HurlShowLastResponse<CR>", desc = "Run All requests" },
		{ "<leader>hj", "<cmd>HurlRunnerAt<CR>", desc = "Run Api request" },
		{ "<leader>he", "<cmd>HurlRunnerToEntry<CR>", desc = "Run Api request to entry" },
		{ "<leader>hE", "<cmd>HurlRunnerToEnd<CR>", desc = "Run Api request from current entry to end" },
		-- { "<leader>hm", "<cmd>HurlToggleMode<CR>", desc = "Hurl Toggle Mode" },
		{ "<leader>hm", "<cmd>HurlManageVariable<CR>", desc = "Hurl Toggle Mode" },
		-- { "<leader>hv", "<cmd>HurlVerbose<CR>", desc = "Run Api in verbose mode" },
		{ "<leader>hv", "<cmd>HurlManageVariable<CR>", desc = "Run Api in verbose mode" },
		{ "<leader>hV", "<cmd>HurlVeryVerbose<CR>", desc = "Run Api in very verbose mode" },
		-- Run Hurl request in visual mode
		{ "<leader>h", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
		{ "a", ":HurlRunner<CR>", desc = "Hurl Runner", mode = "v" },
	},
}
