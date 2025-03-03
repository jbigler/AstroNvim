vim.cmd "autocmd FileType ruby setlocal indentkeys-=."

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
local vim_rails_augroup = vim.api.nvim_create_augroup("vim-rails-augroup", { clear = true })

-- This event will run when vim-rails is detected, as it sets a local variable
vim.api.nvim_create_autocmd("User", {
  pattern = "Rails",
  group = vim_rails_augroup,
  callback = function()
    -- Apply the mapping to the current buffer if it's an erb file
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match "%.erb$" then vim.cmd "cmap <buffer><script><expr> <Plug><cfile> rails#ruby_cfile()" end
  end,
})

-- Also set up the buffer-specific mapping when entering erb files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "eruby" },
  group = vim_rails_augroup,
  callback = function()
    -- Direct way of getting rails detection status
    local is_rails = vim.fn.exists "b:rails_root" == 1

    if is_rails then vim.cmd "cmap <buffer><script><expr> <Plug><cfile> rails#ruby_cfile()" end
  end,
})
--
-- Function to copy the current file path to the system clipboard
-- nmap <leader>cp :let @+ = expand("%")<CR>
