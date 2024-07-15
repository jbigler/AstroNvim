-- Author: Jeff Bigler
-- This snippet enables the OSC 52 clipboard when in a Docker container
-- with the DOCKER environment variable set to "1".
if os.getenv "DOCKER" ~= "1" then return {} end

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
