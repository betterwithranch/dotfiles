-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = ","
vim.opt.cindent = true

vim.opt.updatetime = 300 -- Faster completion updates
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- Faster which-key

vim.g.ai_cmp = true
vim.opt.sessionoptions:append("globals")
