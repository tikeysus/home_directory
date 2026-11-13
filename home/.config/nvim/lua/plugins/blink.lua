return {
	{
		"saghen/blink.cmp",
		opts = {
			completion = {
				menu = {
					-- don't auto-show the completion menu while typing
					auto_show = false,
				},
			},
			keymap = {
				-- accept the current suggestion (ghost text) with Tab,
				-- falling back to snippet-forward / normal Tab otherwise
				["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
			},
			sources = {
				-- the "buffer" source defaults to scanning every buffer visible in
				-- any split, not just the one you're editing -- restrict it to the
				-- current buffer only, so ghost text suggestions stay relevant to
				-- the file you're actually in
				providers = {
					buffer = {
						opts = {
							get_bufnrs = function()
								return { vim.api.nvim_get_current_buf() }
							end,
						},
					},
				},
			},
		},
	},
}
