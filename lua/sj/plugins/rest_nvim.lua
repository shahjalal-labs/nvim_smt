-- plugins/rest.lua or in your plugin config
return {
  "rest-nvim/rest.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "http" }, -- lazy load only on http files
  config = function()
    require("rest-nvim").setup({
      -- Open results in a horizontal split below current window
      result_split_horizontal = false,
      result_split_in_place = false,
      skip_ssl_verification = false,
      highlight = {
        enabled = true,
        timeout = 150,
      },
      result = {
        -- toggle showing URL, HTTP info, headers at top the result window
        show_url = true,
        show_http_info = true,
        show_headers = true,
        -- executables for formatting response body (optional)
        formatters = {
          json = "jq",
          html = function(body)
            return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
          end,
        },
      },
      -- Jump to request line with !
      jump_to_request = false,
      env_file = '.env',
      env_pattern = '\\.env$',
      env_edit_command = 'tabedit',
      custom_dynamic_variables = {},
      yank_dry_run = true,
    })
  end,
}
