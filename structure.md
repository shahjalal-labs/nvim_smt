# 📁 Project Structure

```bash
.
├── init.lua
├── lazy-lock.json
├── lua
│   └── sj
│       ├── core
│       │   ├── custom
│       │   │   ├── ai
│       │   │   │   ├── init.lua
│       │   │   │   └── module_content_combiner.lua
│       │   │   ├── checking2.lua
│       │   │   ├── checking-feature.lua
│       │   │   ├── coding_specific
│       │   │   │   ├── code_explorer.lua
│       │   │   │   ├── init.lua
│       │   │   │   └── prisma_model_navigation_prev.lua
│       │   │   ├── CustomMode
│       │   │   │   ├── init.lua
│       │   │   │   ├── ScrollMode.lua
│       │   │   │   ├── surfingKesy.lua
│       │   │   │   └── surfingKeys.lua
│       │   │   ├── Git
│       │   │   │   ├── autoPush2.lua
│       │   │   │   ├── autoPush.lua
│       │   │   │   ├── clone.lua
│       │   │   │   ├── Github
│       │   │   │   │   ├── github2.lua
│       │   │   │   │   ├── github.lua
│       │   │   │   │   └── init.lua
│       │   │   │   ├── githubDescription.lua
│       │   │   │   ├── githubRepo
│       │   │   │   │   └── gitRepoGeneratePush.lua
│       │   │   │   ├── githubRepoGenerateAndPush.lua
│       │   │   │   ├── init.lua
│       │   │   │   ├── readmeGen2.lua
│       │   │   │   ├── readmeGenerate.lua
│       │   │   │   └── smartCopyPaste.lua
│       │   │   ├── html.lua
│       │   │   ├── HttpApiTesting
│       │   │   │   ├── init.lua
│       │   │   │   └── rest_commands.lua
│       │   │   ├── init.lua
│       │   │   ├── insertMode.lua
│       │   │   ├── JsTsPro
│       │   │   │   ├── init.lua
│       │   │   │   ├── jsTs2.lua
│       │   │   │   ├── jsTs.lua
│       │   │   │   ├── jsxPro2.lua
│       │   │   │   ├── jsxPro.lua
│       │   │   │   ├── jwt_decode.lua
│       │   │   │   ├── reBuildModule.lua
│       │   │   │   └── snippets
│       │   │   │       ├── html.lua
│       │   │   │       ├── init.lua
│       │   │   │       ├── javascript.lua
│       │   │   │       ├── react.lua
│       │   │   │       └── typescript.lua
│       │   │   ├── non_coding
│       │   │   │   ├── init.lua
│       │   │   │   ├── markdown_image_note.lua
│       │   │   │   └── wordExplain.lua
│       │   │   ├── normalModeInInrsert.lua
│       │   │   ├── others.lua
│       │   │   ├── pane_window
│       │   │   │   ├── init.lua
│       │   │   │   └── pane.lua
│       │   │   └── TmuxZshCli
│       │   │       ├── build.lua
│       │   │       ├── fileUtils
│       │   │       │   ├── fileNavigate.lua
│       │   │       │   ├── file_navigation
│       │   │       │   │   ├── init.lua
│       │   │       │   │   ├── navigate_to_controller.lua
│       │   │       │   │   ├── navigate_to_routes.lua
│       │   │       │   │   └── navigate_to_service.lua
│       │   │       │   ├── fileOperation.lua
│       │   │       │   ├── init.lua
│       │   │       │   └── module_files_creation.lua
│       │   │       ├── init.lua
│       │   │       ├── Terminal
│       │   │       │   ├── init.lua
│       │   │       │   └── nvimTerminal.lua
│       │   │       ├── tmuxCommandSender.lua
│       │   │       ├── tmuxPaneContent.lua
│       │   │       ├── tmuxZsh2.lua
│       │   │       └── tmuxZsh.lua
│       │   ├── init.lua
│       │   ├── keymaps.lua
│       │   ├── options.lua
│       │   └── utils.lua
│       ├── lazy.lua
│       └── plugins
│           ├── alpha.lua
│           ├── autopairs.lua
│           ├── autoSave.lua
│           ├── auto-session.lua
│           ├── blammer.lua
│           ├── bufferline.lua
│           ├── colorful-winsep.lua
│           ├── colorscheme.lua
│           ├── comfy-line-numbers.lua
│           ├── comment.lua
│           ├── copilotChat.lua
│           ├── cursor-line.lua
│           ├── dad_bod.lua
│           ├── dbee.lua
│           ├── dressing.lua
│           ├── emoji.lua
│           ├── error-lens.lua
│           ├── flash.lua
│           ├── formatting.lua
│           ├── fzf-lua.lua
│           ├── gh.lua
│           ├── gitsigns.lua
│           ├── grugFar.lua
│           ├── gx.lua
│           ├── hl_match.lua
│           ├── hop.lua
│           ├── hurl.lua
│           ├── image.lua
│           ├── indent-blankline.lua
│           ├── init.lua
│           ├── kulala.lua
│           ├── lazygit.lua
│           ├── linting.lua
│           ├── logsitter.lua
│           ├── lsp
│           │   ├── lspconfig.lua
│           │   └── mason.lua
│           ├── lualine.lua
│           ├── lua-snip.lua
│           ├── mason-workaround.lua
│           ├── md-pdf.lua
│           ├── multi-cursor.lua
│           ├── neoscroll.lua
│           ├── neotree.lua
│           ├── noice.lua
│           ├── nvim-cmp.lua
│           ├── nvim-tree.lua
│           ├── rainbow-matching.lua
│           ├── smearCursor.lua
│           ├── snacks.lua
│           ├── super_maven.lua
│           ├── surround.lua
│           ├── tailwind.lua
│           ├── tailwind-tools.lua
│           ├── telescope.lua
│           ├── tiny_glimmer.lua
│           ├── todo-comments.lua
│           ├── treesitter.lua
│           ├── treesitter-textobjects.lua
│           ├── trouble.lua
│           ├── twilight.lua
│           ├── vim-maximizer.lua
│           ├── web_socket.lua
│           ├── web-tools.lua
│           ├── which-key.lua
│           ├── winshift.lua
│           ├── yanky.lua
│           └── yazi.lua
├── README.md
└── structure.md

22 directories, 140 files

```
