-- ~/.config/nvim/lua/sj/plugins/autoSave.lua
-- SIMPLIFIED VERSION - No complex autocmds

return {
	{
		"okuuva/auto-save.nvim",
		enabled = true,
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
		opts = {
			enabled = true,
			trigger_events = {
				immediate_save = { "BufLeave", "FocusLost", "QuitPre" },
				defer_save = {
					"InsertLeave",
					"TextChanged",
				},
				cancel_deferred_save = {
					"InsertEnter",
				},
			},
			condition = function(buf)
				-- Don't save in insert mode
				if vim.fn.mode() == "i" then
					return false
				end

				local filetype = vim.bo[buf].filetype
				local bufname = vim.fn.bufname(buf)

				-- 🚫 Don't save these filetypes
				local excluded_ft = {
					"harpoon",
					"mysql",
					"sql",
					"dbout",
					"snacks_input",
					"snacks_picker_input",
				}

				if vim.tbl_contains(excluded_ft, filetype) then
					return false
				end

				-- 🚫 Don't save Dad Bod buffers (timestamp pattern)
				if bufname:match("%d%d%d%d%-%d%d%-%d%d%-%d%d%-%d%d%-%d%d") then
					return false
				end

				-- 🚫 Don't save query/result buffers
				if
					bufname:match("^query%-")
					or bufname:match(".*%-Columns%-")
					or bufname:match(".*%-Indexes%-")
					or bufname:match(".*%-References%-")
				then
					return false
				end

				-- ✅ Save everything else
				return true
			end,
			debounce_delay = 2000,
			debug = false,
		},
	},
}
