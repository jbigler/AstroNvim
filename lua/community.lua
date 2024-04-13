if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  { "AstroNvim/astrocommunity" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.markdown-and-latex.peek-nvim" },
  {
    "toppair/peek.nvim",
    opts = { app = "google-chrome-stable", "--new-window" },
  },
  { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  { import = "astrocommunity.completion.copilot-lua" },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        keymap = {
          accept = "<M-g>",
          accept_word = false,
          accept_line = false,
          next = "<M-f>",
          prev = "<M-d>",
          dismiss = "<M-a>",
        },
      },
    },
  },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-endwise" },
  { import = "astrocommunity.file-explorer.oil-nvim" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.motion.nvim-spider" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.motion.vim-matchup" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.clojure" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.full-dadbod" },
  { import = "astrocommunity.project.nvim-spectre" },
  -- import/override with your plugins folder
}
