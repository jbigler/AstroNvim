-- Author: Jeff Bigler
-- with the DOCKER environment variable set to "1" or a podman container
if os.getenv "DOCKER" ~= "1" and os.getenv "container" == nil then return {} end

vim.o.clipboard = "unnamedplus"

local function paste()
  return {
    vim.fn.split(vim.fn.getreg "", "\n"),
    vim.fn.getregtype "",
  }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      g = { -- vim.g.<key>
        clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy "+",
            ["*"] = require("vim.ui.clipboard.osc52").copy "*",
          },
          paste = {
            ["+"] = paste,
            ["*"] = paste,
          },
        },
      },
    },
  },
}
