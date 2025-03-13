local function decode_json_file(filename)
  local file = io.open(filename, "r")
  if file then
    local content = file:read "*all"
    file:close()

    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and type(data) == "table" then return data end
  end
end

local function has_nested_key(json, ...) return vim.tbl_get(json, ...) ~= nil end

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
              filetypes = { "html", "eruby", "ruby" },
              settings = {
                tailwindCSS = {
                  experimental = {
                    classRegex = {
                      'class:\\s*"([^"]*)"',
                      'class=\\s*"([^"]*)"',
                      "class:\\s*'([^']*)'",
                      "class=\\s*'([^']*)'",
                      "%w\\[([^\\]]*)\\]",
                    },
                    configFile = "app/assets/tailwind/application.css",
                  },
                  lint = {
                    invalidApply = "ignore",
                  },
                },
              },
              root_dir = function(fname)
                local root_pattern = require("lspconfig").util.root_pattern

                -- First, check for common Tailwind config files
                local root = root_pattern(
                  "app/assets/tailwind/lsp.css",
                  "tailwind.config.mjs",
                  "tailwind.config.cjs",
                  "tailwind.config.js",
                  "tailwind.config.ts",
                  "postcss.config.js",
                  "config/tailwind.config.js",
                  "app/assets/tailwind.config.js",
                  "app/assets/tailwind/application.css"
                )(fname)
                -- If not found, check for package.json dependencies
                if not root then
                  local package_root = root_pattern "package.json"(fname)
                  if package_root then
                    local package_data = decode_json_file(package_root .. "/package.json")
                    if
                      package_data
                      and (
                        has_nested_key(package_data, "dependencies", "tailwindcss")
                        or has_nested_key(package_data, "devDependencies", "tailwindcss")
                      )
                    then
                      root = package_root
                    end
                  end
                end
                return root
              end,
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
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      { "js-everts/cmp-tailwind-colors", opts = {} },
    },
    opts = function(_, opts)
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        if item.kind == "Color" then
          item = require("cmp-tailwind-colors").format(entry, item)
          if item.kind == "Color" then return format_kinds(entry, item) end
          return item
        end
        return format_kinds(entry, item)
      end
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    optional = true,
    opts = {
      user_default_options = {
        names = true,
        tailwind = true,
      },
    },
  },
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    build = "cd formatter && npm ci && npm run build",
    config = true,
  },
}
