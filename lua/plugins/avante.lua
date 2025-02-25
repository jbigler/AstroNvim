return {
  {
    "yetone/avante.nvim",
    opts = {
      auto_suggestions_provider = "copilot",
      provider = "copilot",
      copilot = {
        model = "claude-3.7-sonnet",
        temperature = 0,
        max_tokens = 8192,
      },
    },
  },
}
