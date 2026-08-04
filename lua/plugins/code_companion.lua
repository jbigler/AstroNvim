local prefix = "<Leader>A"

--- render-markdown <-> CodeCompanion stale-tree guard -------------------------
--
-- render-markdown parses the buffer's treesitter tree and then reads node text
-- inside a `vim.schedule` callback. CodeCompanion -- especially the ACP adapter
-- -- rewrites regions of the chat buffer *in place* while streaming (tool call
-- blocks and reasoning sections get replaced over shrinking ranges, not just
-- appended). By the time the scheduled callback runs, a node's range can point
-- past the new end of the buffer and `nvim_buf_get_text` raises
-- "Index out of bounds" out of vim/treesitter.lua.
--
-- Fix: pause rendering for the duration of a chat turn, resume once things go
-- quiet. Side benefit -- no anti-conceal jitter while tokens stream in.

local RMD_QUIET_MS = 1200 -- grace period after a request, in case a tool loop starts another
local RMD_DONE_MS = 100 -- turn is genuinely over, hand the buffer back promptly

---@type table<integer, integer> bufnr -> generation, used to cancel pending resumes
local rmd_gen = {}

---@param buf integer
---@param enable boolean
local function rmd_set(buf, enable)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local ok, rmd = pcall(require, "render-markdown")
  if not ok then return end
  -- `buf_enable`/`buf_disable` act on the *current* buffer, so borrow it briefly
  pcall(vim.api.nvim_buf_call, buf, function()
    if enable then
      rmd.buf_enable()
    else
      rmd.buf_disable()
    end
  end)
end

---@param buf integer
local function rmd_pause(buf)
  rmd_gen[buf] = (rmd_gen[buf] or 0) + 1 -- invalidates any in-flight resume
  rmd_set(buf, false)
end

---@param buf integer
---@param delay integer
local function rmd_resume(buf, delay)
  local gen = (rmd_gen[buf] or 0) + 1
  rmd_gen[buf] = gen
  vim.defer_fn(function()
    if rmd_gen[buf] == gen then rmd_set(buf, true) end
  end, delay)
end

-- CodeCompanion fires these as `User CodeCompanion<Event>` with `data.bufnr`.
-- ChatSubmitted fires again for every tool-loop auto-submit; ChatDone fires
-- once when the whole turn ends. Bracketing on those survives tool loops
-- without flickering, and the debounced RequestFinished is a safety net in case
-- ChatDone never arrives (e.g. an adapter error path).
local rmd_handlers = {
  CodeCompanionChatSubmitted = function(buf) rmd_pause(buf) end,
  CodeCompanionRequestStarted = function(buf) rmd_pause(buf) end,
  CodeCompanionRequestFinished = function(buf) rmd_resume(buf, RMD_QUIET_MS) end,
  CodeCompanionChatDone = function(buf) rmd_resume(buf, RMD_DONE_MS) end,
  CodeCompanionChatStopped = function(buf) rmd_resume(buf, RMD_DONE_MS) end,
  CodeCompanionChatClosed = function(buf) rmd_gen[buf] = nil end,
}

return {
  {
    "olimorris/codecompanion.nvim",
    event = "User AstroFile",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
    },
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
                  CLAUDE_CODE_OAUTH_TOKEN = "PRIVATE_CLAUDE_CODE_TOKEN_FOR_NVIM",
                },
              })
            end,
          },
          http = {
            turbollm = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                name = "turbollm",
                formatted_name = "TurboLLM (local)",
                env = {
                  url = "http://192.168.1.50:9009",
                  api_key = "LLM_KEY",
                  chat_url = "/v1/chat/completions",
                },
                schema = {
                  model = {
                    default = "qwen-general",
                    choices = {
                      "qwen-general",
                      "ornith-coder",
                    },
                  },
                },
              })
            end,
          },
        },
        interactions = {
          chat = {
            adapter = {
              name = "claude_code",
              model = "Opus",
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
          opts.autocmds = opts.autocmds or {}
          opts.autocmds.codecompanion_render_markdown = {
            {
              event = "User",
              pattern = vim.tbl_keys(rmd_handlers),
              desc = "Pause render-markdown while CodeCompanion streams into the chat buffer",
              callback = function(args)
                local buf = args.data and args.data.bufnr
                local handler = rmd_handlers[args.match]
                if not (buf and handler) then return end
                if not vim.api.nvim_buf_is_valid(buf) then
                  rmd_gen[buf] = nil
                  return
                end
                -- Request events also fire for the inline assistant, where bufnr
                -- is a source buffer. Only touch the chat buffer.
                if vim.bo[buf].filetype ~= "codecompanion" then return end
                handler(buf)
              end,
            },
          }

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
          local astrocore = require "astrocore"

          if not opts.file_types then opts.file_types = { "markdown" } end
          opts.file_types = astrocore.list_insert_unique(opts.file_types, { "codecompanion" })

          -- Fewer parse cycles means fewer windows for the schedule callback to
          -- race buffer mutation. Scoped via `overrides.filetype` so ordinary
          -- markdown editing keeps the snappy 100ms default.
          opts.overrides = opts.overrides or {}
          opts.overrides.filetype = opts.overrides.filetype or {}
          opts.overrides.filetype.codecompanion =
            astrocore.extend_tbl(opts.overrides.filetype.codecompanion or {}, { debounce = 300 })
        end,
      },
    },
  },
}
