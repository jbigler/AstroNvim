return {
  "junegunn/goyo.vim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          -- 'n' is for Normal mode
          n = {
            -- Your desired keymap
            ["<Leader>G"] = {
              function()
                -- Execute the command with the 120 line argument
                vim.cmd "Goyo 120"
              end,
              desc = "Toggle Goyo Mode (120 lines)",
            },
          },
        },
      },
    },
  },
}
