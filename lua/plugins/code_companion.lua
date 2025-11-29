local prefix = "<Leader>A"

return {
  {
    "olimorris/codecompanion.nvim",
    event = "User AstroFile",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function()
      return {
        strategies = {
          chat = {
            adapter = {
              name = "copilot",
              model = "claude-sonnet-4.5",
            },
          },
          inline = {
            adapter = {
              name = "copilot",
              model = "copilot",
            },
          },
          cmd = {
            adapter = {
              name = "copilot",
              model = "grok-code-fast-1",
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
    specs = {
      {
        "rebelot/heirline.nvim",
        optional = true,

        opts = function(_, opts)
          opts.statusline = opts.statusline or {}
          local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
          local astroui = require "astroui.status.hl"
          table.insert(opts.statusline, {
            static = {
              n_requests = 0,
              spinner_index = 0,
              spinner_symbols = spinner_symbols,
              done_symbol = "✓",
            },
            init = function(self)
              if self._cc_autocmds then return end
              self._cc_autocmds = true
              vim.api.nvim_create_autocmd("User", {
                pattern = "CodeCompanionRequestStarted",
                callback = function()
                  self.n_requests = self.n_requests + 1
                  vim.cmd "redrawstatus"
                end,
              })
              vim.api.nvim_create_autocmd("User", {
                pattern = "CodeCompanionRequestFinished",
                callback = function()
                  self.n_requests = math.max(0, self.n_requests - 1)
                  vim.cmd "redrawstatus"
                end,
              })
            end,
            provider = function(self)
              if not package.loaded["codecompanion"] then return nil end
              local symbol
              if self.n_requests > 0 then
                self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
                symbol = self.spinner_symbols[self.spinner_index]
              else
                symbol = self.done_symbol
                self.spinner_index = 0
              end
              return ("%d %s"):format(self.n_requests, symbol)
            end,
            hl = function() return astroui.filetype_color() end,
          })
        end,
      },
      {
        "AstroNvim/astroui",
        opts = { icons = { CodeCompanion = "󱙺" } },
      },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = {} end
          opts.mappings.n = opts.mappings.n or {}
          opts.mappings.v = opts.mappings.v or {}
          opts.mappings.n[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          opts.mappings.v[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          opts.mappings.n[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
          opts.mappings.v[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
          opts.mappings.n[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
          opts.mappings.v[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
          opts.mappings.n[prefix .. "q"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
          opts.mappings.v[prefix .. "q"] = { "<cmd>CodeCompanion<cr>", desc = "Open inline assistant" }
          opts.mappings.v[prefix .. "a"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat" }
        end,
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
    },
  },
}
