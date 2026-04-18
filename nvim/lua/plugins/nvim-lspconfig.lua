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
				clangd = {},
				lua_ls = {},
				nixd = {},
				pyright = { enabled = false },
				ty = {},
			},
		},
	},
}
