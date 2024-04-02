return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      -- first key is the mode
      n = {
        ["<leader>q"] = {
          function()
            for _, ui in pairs(vim.api.nvim_list_uis()) do
              if ui.chan and not ui.stdout_tty then
                vim.fn.chanclose(ui.chan)
              else
                vim.cmd "confirm q"
              end
            end
          end,
          desc = "Disconnect from Remote Neovim",
        },
      },
    },
  },
}
