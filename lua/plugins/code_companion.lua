return {
  {
    "olimorris/codecompanion.nvim",
    event = "User AstroFile",
    opts = function()
      return {
        strategies = {
          chat = {
            adapter = {
              name = "copilot",
              model = "claude-sonnet-4",
            },
          },
          inline = {
            adapter = {
              name = "copilot",
              model = "gpt-5",
            },
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              show_result_in_chat = true, -- Show mcp tool results in chat
              make_vars = true, -- Convert resources to #variables
              make_slash_commands = true, -- Add prompts as /slash commands
            },
          },
          vectorcode = {
            ---@type VectorCode.CodeCompanion.ExtensionOpts
            -- opts = {
            --   tool_group = {
            --     -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
            --     enabled = true,
            --     -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
            --     -- if you use @vectorcode_vectorise, it'll be very handy to include
            --     -- `file_search` here.
            --     extras = {},
            --     collapse = false, -- whether the individual tools should be shown in the chat
            --   },
            --   tool_opts = {
            --     ---@type VectorCode.CodeCompanion.ToolOpts
            --     ["*"] = {},
            --     ---@type VectorCode.CodeCompanion.LsToolOpts
            --     ls = {},
            --     ---@type VectorCode.CodeCompanion.VectoriseToolOpts
            --     vectorise = {},
            --     ---@type VectorCode.CodeCompanion.QueryToolOpts
            --     query = {
            --       max_num = { chunk = -1, document = -1 },
            --       default_num = { chunk = 50, document = 10 },
            --       include_stderr = false,
            --       use_lsp = false,
            --       no_duplicate = true,
            --       chunk_mode = false,
            --       ---@type VectorCode.CodeCompanion.SummariseOpts
            --       ---@diagnostic disable-next-line missing-fields
            --       summarise = {
            --         ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
            --         enabled = false,
            --         adapter = nil,
            --         query_augmented = true,
            --       },
            --     },
            --     files_ls = {},
            --     files_rm = {},
            --   },
            -- },
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Davidyz/VectorCode",
      "ravitemer/mcphub.nvim",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.file_types then opts.file_types = { "markdown" } end
      opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "codecompanion" })
    end,
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest",
    config = function() require("mcphub").setup() end,
  },
  {
    "Davidyz/VectorCode",
    lazy = true,
    version = "*", -- optional, depending on whether you're on nightly or release
    build = "uv tool upgrade 'vectorcode[lsp,mcp]'",
    ---@module 'vectorcode'
    ---@type VectorCode.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      async_backend = "lsp",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "VectorCode", -- if you're lazy-loading VectorCode
  },
}
