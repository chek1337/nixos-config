return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        nixd = {},
        pyright = { enabled = false },
        ty = {},
      },
    },
  },
}
