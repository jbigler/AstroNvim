return {
  "pwntester/octo.nvim",
  opts = {
    use_local_fs = true,
    gh_env = function() return { GH_TOKEN = vim.env.GH_TOKEN } end,
  },
}
