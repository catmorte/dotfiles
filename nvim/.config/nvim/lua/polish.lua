-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.cmd "colorscheme catppuccin-frappe"
vim.cmd "set guicursor=i:ver1"
vim.cmd "set guicursor+=a:blinkon1"
vim.g.tabby_trigger_mode = "manual"
vim.g.tabby_keybinding_accept = "<C-l>"
vim.g.tabby_keybinding_trigger_or_dismiss = "<C-e>"
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
