return {
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      local minitest = require "neotest-minitest"
      opts.adapters = {
        minitest,
      }
    end,
  },
}
