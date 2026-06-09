return {
  { import = "astrocommunity.pack.html-css" },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "tailwindcss" })
    end,
    dependencies = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          config = {
            tailwindcss = {
              filetypes = { "html", "eruby", "ruby", "css" },
              settings = {
                tailwindCSS = {
                  experimental = {
                    classRegex = {
                      'class:\\s*"([^"]*)"',
                      'class=\\s*"([^"]*)"',
                      "class:\\s*'([^']*)'",
                      "class=\\s*'([^']*)'",
                      "%w\\[([^\\]]*)\\]",
                      -- class_names("foo", "bar") -> grab inside parens, then each quoted string
                      { "class_names\\(([^)]*)\\)", "[\"']([^\"']*)[\"']" },
                    },
                    -- configFile = "app/assets/tailwind/application.css",
                  },
                  -- lint = {
                  --   invalidApply = "ignore",
                  -- },
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "tailwindcss-language-server" })
    end,
  },
  -- Disabled in favor of oklch-color-picker.nvim (supports oklch()).
  { "NvChad/nvim-colorizer.lua", optional = true, enabled = false },
}
