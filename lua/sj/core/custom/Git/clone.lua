local function clone_github_raw_to_current_dir()
	-- 📋 Step 1: Get GitHub URL from clipboard
	local github_url = vim.fn.getreg("+") -- + means system clipboard

	if not github_url:match("https://github.com/") then
		print("❌ Clipboard doesn't contain a GitHub file URL.")
		return
	end

	-- 🔄 Step 2: Convert GitHub URL to raw.githubusercontent URL
	local raw_url = github_url:gsub("https://github.com/", "https://raw.githubusercontent.com/"):gsub("/blob/", "/")

	-- 🧾 Step 3: Extract filename from URL
	local filename = raw_url:match("/([^/]+)$") or "downloaded.js"

	-- 📂 Step 4: Get directory of current buffer
	local current_dir = vim.fn.expand("%:p:h")

	-- 🧪 Optional: Confirm download
	print("📥 Downloading " .. filename .. " to " .. current_dir)

	-- 🐚 Step 5: Run curl to download
	local cmd = string.format("curl -sSL -o %s/%s %s", current_dir, filename, raw_url)
	vim.fn.system(cmd)

	print("✅ Download complete: " .. filename)
end

vim.keymap.set("n", "<leader>gf", clone_github_raw_to_current_dir, {
	desc = "📥 Clone GitHub File from Clipboard into Current File's Directory",
})
