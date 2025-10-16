vim.keymap.set("n", "<leader>sw", function()
	local cwd = vim.fn.getcwd()
	local screenshots_dir = cwd .. "/src/assets/screenshots"
	local readme_path = cwd .. "/README.md"

	-- Ensure screenshots directory exists
	vim.fn.mkdir(screenshots_dir, "p")

	-- Compose the bash screenshot command
	local bash_cmd = string.format(
		[[
    f="%s/ss-$(LC_TIME=C date +%%I-%%M-%%S-%%p_%%d-%%m-%%y).png";
    grim -g "$(slurp)" "$f" &&
    wl-copy --type image/png < "$f" &&
    echo "![Screenshot](src/assets/screenshots/$(basename "$f"))"
  ]],
		screenshots_dir
	)

	-- Run bash command and capture markdown image line
	local output = vim.fn.systemlist({ "bash", "-c", bash_cmd })

	if output and #output > 0 then
		local md_line = output[1]

		-- Append markdown line to README.md
		local file = io.open(readme_path, "a")
		if file then
			file:write("\n" .. md_line .. "\n")
			file:close()
			print("🖼️ Screenshot saved and appended to README.md")
		else
			print("❌ Failed to open README.md for appending")
		end
	else
		print("❌ Screenshot failed")
	end
end, { desc = "Area select screenshot + append markdown to README.md" })
