-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-save: write the buffer whenever you leave insert mode, stop typing
-- for a moment, or switch away from it -- mirrors how Mac-style editors
-- persist changes without an explicit save.
local autosave_group = vim.api.nvim_create_augroup("autosave", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
	group = autosave_group,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if
			vim.bo[buf].modifiable
			and not vim.bo[buf].readonly
			and vim.bo[buf].buftype == ""
			and vim.api.nvim_buf_get_name(buf) ~= ""
			and vim.bo[buf].modified
		then
			vim.cmd("silent! write")
		end
	end,
})
