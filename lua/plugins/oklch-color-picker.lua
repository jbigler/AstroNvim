local enabled_lsps = { "tailwindcss", "cssls", "css_variables" }

-- tailwindcss-language-server registers documentColor dynamically, after it
-- resolves the project's CSS entry point -- well after LspAttach. The plugin
-- asks for LSP colors on attach and then only on edits, so custom @theme
-- tokens (bg-primary, divide-neutral-border) stay unhighlighted until the
-- buffer is touched: its built-in Tailwind table only knows the stock palette.
local function refresh_when_supported(client, buf)
  local method = "textDocument/documentColor"
  if not vim.tbl_contains(enabled_lsps, client.name) then return end

  local hl = require "oklch-color-picker.highlight"
  local function refresh()
    local buf_data = hl.get_buf_data(buf)
    if buf_data then hl.update_lsp(buf, buf_data) end
  end

  if client:supports_method(method, buf) then return refresh() end

  local tries = 0
  local timer = assert(vim.uv.new_timer())
  timer:start(
    250,
    250,
    vim.schedule_wrap(function()
      tries = tries + 1
      local give_up = tries > 40 or client:is_stopped() or not vim.api.nvim_buf_is_valid(buf)
      local ready = not give_up and client:supports_method(method, buf)
      if not (give_up or ready) then return end
      timer:stop()
      timer:close()
      if ready then refresh() end
    end)
  )
end

return {
  {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    version = "*",
    keys = {
      {
        "<Leader>v",
        function() require("oklch-color-picker").pick_under_cursor() end,
        desc = "Color pick under cursor",
      },
    },
    ---@type oklch.Opts
    opts = {
      highlight = {
        style = "background",
        enabled_lsps = enabled_lsps,
      },
    },
    config = function(_, opts)
      require("oklch-color-picker").setup(opts)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("oklch_late_lsp_colors", {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then refresh_when_supported(client, args.buf) end
        end,
      })

      -- Plugin loads on VeryLazy, so startup clients already fired LspAttach.
      for _, client in ipairs(vim.lsp.get_clients()) do
        for buf in pairs(client.attached_buffers or {}) do
          if vim.api.nvim_buf_is_valid(buf) then refresh_when_supported(client, buf) end
        end
      end
    end,
  },
}

--
-- return {
--   {
--     "eero-lehtinen/oklch-color-picker.nvim",
--     event = "VeryLazy",
--     version = "*",
--     keys = {
--       {
--         "<Leader>v",
--         function() require("oklch-color-picker").pick_under_cursor() end,
--         desc = "Color pick under cursor",
--       },
--     },
--     ---@type oklch.Opts
--     opts = {
--       highlight = {
--         style = "background",
--         enabled_lsps = { "tailwindcss", "cssls", "css_variables" },
--       },
--     },
--   },
-- }
