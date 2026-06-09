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
        enabled_lsps = { "tailwindcss", "cssls", "css_variables" },
      },
    },
  },
}
