--if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Helper function to prepend mise command
local function prepend_mise(cmd)
  if vim.fn.executable "mise" == 1 then
    if type(cmd) == "string" then
      return "mise x -- " .. cmd
    elseif type(cmd) == "table" then
      local result = { "mise", "x", "--" }
      for _, item in ipairs(cmd) do
        table.insert(result, item)
      end
      return result
    end
  end
  return cmd
end

-- Function to determine the correct command for erb_lint
local function get_erb_lint_command()
  local has_gemfile = vim.fn.filereadable "Gemfile" == 1
  local has_erb_lint_in_bundle = false

  -- Check if erb_lint is available via bundler
  if has_gemfile then
    local bundle_list_cmd = "bundle list | grep -q erb_lint"
    bundle_list_cmd = prepend_mise(bundle_list_cmd)

    local exit_code = vim.fn.system(bundle_list_cmd) == 0 and 0 or 1
    has_erb_lint_in_bundle = exit_code == 0
  end

  local cmd = has_erb_lint_in_bundle and { "bundle", "exec", "erb_lint" } or { "erb_lint" }
  cmd = prepend_mise(cmd)

  return cmd
end

-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Set a formatter
      -- null_ls.builtins.formatting.stylua,
      -- null_ls.builtins.formatting.prettier,

      -- ERB Lint using dynamic command determination
      null_ls.builtins.diagnostics.erb_lint.with {
        command = get_erb_lint_command(),
      },
      null_ls.builtins.formatting.erb_lint.with {
        command = get_erb_lint_command(),
      },
    })
  end,
}
