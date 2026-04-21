local function ruby_lsp_cmd()
  if vim.fn.executable "mise" == 1 then
    return { "mise", "x", "--", "ruby-lsp" }
  else
    return { "ruby-lsp" }
  end
end

local function add_ruby_deps_command(client, bufnr)
  vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
    local params = vim.lsp.util.make_text_document_params()
    local showAll = opts.args == "all"

    client.request("rubyLsp/workspace/dependencies", params, function(error, result)
      if error then
        print("Error showing deps: " .. error)
        return
      end

      local qf_list = {}
      for _, item in ipairs(result) do
        if showAll or item.dependency then
          table.insert(qf_list, {
            text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
            filename = item.path,
          })
        end
      end

      vim.fn.setqflist(qf_list)
      vim.cmd "copen"
    end, bufnr)
  end, { nargs = "?", complete = function() return { "all" } end })
end

return {
  mason = false,
  cmd = ruby_lsp_cmd(),
  on_attach = function(client, buffer) add_ruby_deps_command(client, buffer) end,
  init_options = {
    formatter = "auto",
    enabledFeatures = {
      codeActions = true,
      diagnostics = true,
      documentHighlights = true,
      documentLink = true,
      documentSymbols = true,
      foldingRanges = true,
      formatting = true,
      hover = true,
      inlayHint = true,
      selectionRanges = true,
      completion = true,
      codeLens = false,
      definition = true,
      workspaceSymbol = true,
      signatureHelp = true,
    },
    featuresConfiguration = {
      inlayHint = {
        implicitHashValue = true,
        implicitRescue = true,
      },
    },
    experimentalFeaturesEnabled = true,
  },
}
