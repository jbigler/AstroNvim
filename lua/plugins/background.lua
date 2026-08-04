-- Author: Jeff Bigler
-- Apply the light/dark mode passed in as NVIM_BACKGROUND.
--
-- Neovim normally figures this out by querying the terminal with OSC 11, but that
-- only happens when a UI with `stdout_tty` is already attached at startup (the
-- `if tty then` guard in runtime/lua/vim/_core/defaults.lua). The nvim container
-- runs `nvim --headless --listen` and clients attach later with `nvim --remote-ui`,
-- so there is no UI at startup, the detection is skipped, and 'background' would
-- stay at its default of "dark" forever. The container gets the answer from the
-- host terminal instead — see .scripts/detect-terminal-background.sh in the
-- filial-rails-core repo.
--
-- This runs while lazy.nvim collects specs, before AstroUI applies the
-- colorscheme, so the value is in place for the first paint. Outside the
-- container NVIM_BACKGROUND is unset and Neovim's own detection is left alone.

--- Set 'background' and repaint.
---
--- Re-applying the colorscheme is what actually repaints: changing 'background'
--- alone does nothing, but colors/flexoki.lua clears the cached palette module on
--- reload and flexoki/palette.lua then picks its variant off 'background'.
---
--- Global because the `mise run nvim` task calls it over RPC as
--- `v:lua.BackgroundSet('dark')` before attaching, so a client always gets the
--- host terminal's current mode even though NVIM_BACKGROUND was frozen when the
--- container started.
---
---@param mode string? "dark" or "light"; anything else is ignored
---@return string background The mode in effect after the call
function _G.BackgroundSet(mode)
  if (mode == "dark" or mode == "light") and mode ~= vim.o.background then
    vim.o.background = mode
    if vim.g.colors_name then vim.cmd.colorscheme(vim.g.colors_name) end
  end

  return vim.o.background
end

_G.BackgroundSet(vim.env.NVIM_BACKGROUND)

vim.api.nvim_create_user_command(
  "BackgroundToggle",
  function() _G.BackgroundSet(vim.o.background == "dark" and "light" or "dark") end,
  { desc = "Toggle between a light and dark background" }
)

---@type LazySpec
return {}
