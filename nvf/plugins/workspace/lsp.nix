{ ... }:
{
  vim.luaConfigRC.workspace-lsp = # lua
    ''
      vim.lsp.config("*", {
        before_init = function(params, config)
          local ok, mod = pcall(require, "chek.workspace")
          if ok then mod.before_init(params, config) end
        end,
      })
    '';
}
