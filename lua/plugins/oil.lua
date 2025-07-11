return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>F"] = { function() require("oil").open_float() end, desc = "Open folder in Oil" },
            },
          },
        },
      },
    },
  },
  {
    "benomahony/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
    opts = {},
  },
}
