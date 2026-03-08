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
        adapters = {
          acp = {
            claude_code = function()
              return require("codecompanion.adapters").extend("claude_code", {
                env = {
                  CLAUDE_CODE_OAUTH_TOKEN = "CLAUDE_CODE_OAUTH_TOKEN",
                },
              })
            end,
          },
        },
        interactions = {
          chat = {
            adapter = {
              name = "copilot",
              model = "claude-opus-4.6",
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
              make_vars = false, -- Convert resources to #variables TODO: put back after fix
              make_slash_commands = true, -- Add prompts as /slash commands
            },
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
    },
  },
}
