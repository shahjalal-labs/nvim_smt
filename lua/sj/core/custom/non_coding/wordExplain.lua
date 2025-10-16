local M = {}

-- Base directory for saving word files
local base_path = "/run/media/sj/developer/knowledge/english/words/wordExplainPrompts/"

function M.create_word_file()
	-- Ensure directory exists
	vim.fn.mkdir(base_path, "p")

	-- Get word from clipboard
	local word = vim.fn.getreg("+")
	if not word or word == "" then
		print("Clipboard is empty! Copy a word first.")
		return
	end
	word = word:gsub("%s+", "") -- remove spaces/newlines

	-- Count existing files to determine suffix
	local files = vim.fn.globpath(base_path, "*.md", 0, 1)
	local count = #files + 1
	local filename = string.format("%s%s%d.md", base_path, word, count)

	-- Create the file if it doesn't exist
	if vim.fn.filereadable(filename) == 0 then
		vim.fn.writefile({}, filename)
	end

	-- Open the new file in the current tab
	vim.cmd("edit " .. filename)

	-- Generate LLM prompt
	local prompt = [[
Give me a detailed word study of "]] .. word .. [[" with the following structure:

    Part of Speech

    Meaning

        English meaning

        Bangla meaning

    Pronunciation

        English (IPA + phonetic)

        Bangla (Bangla letters spelling the English word)

    Synonyms (3)

        Format: Word — Bangla pronunciation — Bangla meaning

    Antonyms (3)

        Format: Word — Bangla pronunciation — Bangla meaning

    Word Family / Related Forms

    Collocations / Common Phrases

    Example Sentences (3 levels: simple, medium, advanced)

        Each sentence: English + Bangla translation

    Etymology (word origin)

    Memory Hook / Visual Cue for recall

    TRY TO GIVE THE ENTIRE APPROACH IN TABLE VIEW FORMAT.

]]
	-- Insert the prompt into the buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(prompt, "\n"))

	-- Copy prompt to clipboard
	vim.fn.setreg("+", prompt)
	print("LLM prompt copied to clipboard and inserted into: " .. filename)
end

-- Map <leader>ww to run the function in normal mode
vim.api.nvim_set_keymap(
	"n",
	"<leader>ww",
	[[:lua require'sj.core.custom.non_coding.wordExplain'.create_word_file()<CR>]],
	{ noremap = true, silent = true }
)

return M
