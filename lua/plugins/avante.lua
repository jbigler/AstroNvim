return {
  {
    "yetone/avante.nvim",
    opts = {
      copilot = {
        endpoint = "https://api.githubcopilot.com/",
        -- model = "o3-mini"
        model = "claude-3.7-sonnet",
        proxy = nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false, -- Allow insecure server connections
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 8192,
      },
    },
  },
}
