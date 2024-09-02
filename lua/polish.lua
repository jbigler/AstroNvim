if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }

-- This will set gf to work in erb files, but only if the Rails plugin is loaded.
-- Right now I'm using treesitter by turning on additional_vim_regex_highlighting.
-- But that can cause performance issues, so use this if you want to avoid that.
-- local vim_rails_augroup = vim.api.nvim_create_augroup("vim-rails-augroup", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--   pattern = { "*.erb" },
--   group = vim_rails_augroup,
--   callback = function()
--     vim.cmd "if RailsDetect() | cmap <buffer><script><expr> <Plug><cfile> rails#ruby_cfile() | endif"
--   end,
-- })
