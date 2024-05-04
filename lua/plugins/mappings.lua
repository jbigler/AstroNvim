return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          ["<Leader>q"] = {
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
          -- Page up and down go to center of screen
          ["<C-u>"] = { "<C-u>zz", desc = "Half page up" },
          ["<C-d>"] = { "<C-d>zz", desc = "Half page down" },
          ["n"] = { "nzzzv", desc = "Move to next search item" },
          ["N"] = { "Nzzzv", desc = "Move to previous search item" },
          ["C-f"] = { "C-fzz", desc = "Page down" },
          ["C-b"] = { "C-bzz", desc = "Page up" },
        },
      },
    },
  },
}
