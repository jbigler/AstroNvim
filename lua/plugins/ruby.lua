vim.g.rails_projections = {
  ["app/components/*_component.rb"] = {
    ["type"] = "component",
    ["related"] = "app/components/{}_component.html.erb",
  },
  ["app/components/*_component.html.erb"] = {
    ["type"] = "template",
    ["related"] = "app/components/{}_component.rb",
  },
  ["test/models/*_test.rb"] = {
    ["command"] = "modeltest",
  },
}

return {
  { "zidhuss/neotest-minitest" },
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function() require("luasnip").filetype_extend("ruby", { "rails" }) end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(
          opts.ensure_installed,
          { "ruby", "embedded_template", "sql", "regex" }
        )
      end
      opts.highlight = {
        enable = true,
        -- Disable due to issues with incorrect block detection
        -- additional_vim_regex_highlighting = { "ruby" },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "suketa/nvim-dap-ruby", config = true },
    },
    config = function()
      local dap = require "dap"
      table.insert(dap.configurations.ruby, 1, {
        type = "ruby",
        name = "Debug file on remote server (app)",
        bundle = "bundle",
        request = "attach",
        command = "ruby",
        script = "${file}",
        port = 38698,
        server = "app",
        options = {
          source_filetype = "ruby",
        },
        localfs = true,
        waiting = 1000,
      })
      table.insert(dap.configurations.ruby, 2, {
        type = "ruby",
        name = "Debug file in container",
        request = "attach",
        bundle = "bundle",
        command = "ruby",
        script = "${file}",
        port = 38698,
        server = "127.0.0.1",
        options = {
          source_filetype = "ruby",
        },
        localfs = false,
        localfsMap = vim.env.RUBY_DEBUG_LOCAL_FS_MAP,
        waiting = 1000,
      })
    end,
  },
  {
    "tpope/vim-rails",
    config = function()
      -- For some reason this one won't work, it just opens the alternate
      -- vim.api.nvim_create_user_command("RC", function() vim.cmd("e " .. vim.fn.eval "rails#buffer().related()") end, {})
      vim.api.nvim_create_user_command(
        "AC",
        function() vim.cmd("e " .. vim.fn.eval "rails#buffer().alternate()") end,
        {}
      )
      -- disable autocmd set filetype=eruby.yaml
      vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
        pattern = { "*.yml" },
        callback = function() vim.bo.filetype = "yaml" end,
      })
      -- vim.cmd "cmap <buffer><script><expr> <Plug><cfile> rails#ruby_cfile()"
    end,
  },
}
