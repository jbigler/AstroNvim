-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  { "AstroNvim/astrocommunity" },
  { import = "astrocommunity.bars-and-lines.vim-illuminate" },
  { import = "astrocommunity.color.nvim-highlight-colors" },
  {
    "toppair/peek.nvim",
    opts = { app = "google-chrome-stable", "--new-window" },
  },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.completion.copilot-cmp" },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   opts = {
  --     suggestion = {
  --       keymap = {
  --         accept = "<M-g>",
  --         accept_word = false,
  --         accept_line = false,
  --         next = "<M-f>",
  --         prev = "<M-d>",
  --         dismiss = "<M-a>",
  --       },
  --     },
  --   },
  -- },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.docker.lazydocker" },
  -- { import = "astrocommunity.editing-support.copilotchat-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-endwise" },
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  { import = "astrocommunity.editing-support.text-case-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.editing-support.undotree" },
  { import = "astrocommunity.file-explorer.oil-nvim" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.git.octo-nvim" },
  { import = "astrocommunity.git.gitlinker-nvim" },
  { import = "astrocommunity.markdown-and-latex.peek-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.motion.vim-matchup" },
  { import = "astrocommunity.motion.nvim-spider" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.clojure" },
  { import = "astrocommunity.pack.chezmoi" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.full-dadbod" },
  { import = "astrocommunity.split-and-window.mini-map" },
  -- import/override with your plugins folder
}
