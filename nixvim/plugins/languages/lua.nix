{ pkgs, config, ... }:
{
  # plugins.lsp.servers.lua_ls.enable = true;
  #
  # plugins.lazydev = {
  #   enable = true;
  #   lazyLoad.settings.ft = "lua";
  # };
  #
  # plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
  #   lua
  # ];
  #
  # plugins.conform-nvim.settings.formatters_by_ft.lua = [ "stylua" ];
  #
  # plugins.lint.lintersByFt.lua = [ "luacheck" ];
  #
  # extraPackages = with pkgs; [
  #   lua-language-server
  #   stylua
  #   luajitPackages.luacheck
  # ];
}
