-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Wider, more pronounced indentation (default is 2 spaces)
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Hide whitespace markers (tab/trail/nbsp arrows and dots)
vim.opt.list = false

-- Absolute line numbers (LazyVim defaults to relative, i.e. distance from cursor)
vim.opt.relativenumber = false

-- Thin vertical-bar cursor in every mode (not just Insert), like VS Code's
-- caret, instead of Vim's default block in Normal/Visual/Command mode
vim.opt.guicursor = "n-v-c-sm-i-ci-ve-r-cr-o:ver25"

-- Soft-wrap long lines (LazyVim defaults wrap off, which forces horizontal
-- scrolling in narrow split panes). linebreak wraps at word boundaries rather
-- than mid-word, and breakindent keeps continuation rows at the original
-- indent so wrapped code still lines up.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
