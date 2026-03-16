return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["*"] = {
					keys = {
						{ "K", false },
					},
				},
				lua_ls = {},
				nixd = {},
				pyright = { enabled = false },
				ty = {},
			},
		},
	},
}
