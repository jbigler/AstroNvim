return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "ruby" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "ruby_lsp" })
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
        bundle = "bundle",
        request = "attach",
        command = "ruby",
        script = "${file}",
        port = 38698,
        server = "127.0.0.1",
        options = {
          source_filetype = "ruby",
        },
        localfs = false,
        waiting = 1000,
      })
    end,
  },
  {
    "tpope/vim-rails",
    config = function()
      vim.api.nvim_create_user_command(
        "AC",
        function() vim.cmd("e " .. vim.fn.eval "rails#buffer().alternate()") end,
        {}
      )
    end,
  },
  {
    "tpope/vim-abolish",
    lazy = false,
  },
}
