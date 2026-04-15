-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.treesitter.query.add_predicate("is-mise?", function(_match, _pattern, source, _predicate)
        local bufnr = type(source) == "number" and source or 0
        local filepath = vim.api.nvim_buf_get_name(bufnr)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        return string.match(filename, ".*mise.*%.toml$") ~= nil
      end, { force = true, all = false })
    end,
  },
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      enabled = function(_lang, buf) return vim.bo[buf].buftype == "" end,
      highlight = true, -- enable/disable treesitter based highlighting
      indent = true, -- enable/disable treesitter based indentation
      auto_install = true, -- enable/disable automatic installation of detected languages
      ensure_installed = {
        "lua",
        "vim",
        "bash",
        "toml",
        "zsh",
        -- add more arguments for adding more treesitter parsers
      },
    },
  },
}
