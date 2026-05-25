{ pkgs, config, ... }:
{
  plugins.lsp.servers.jsonls.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    json
    json5
  ];

  plugins.conform-nvim.settings.formatters_by_ft = {
    json = [ "jsonfmt" ];
    jsonc = [ "jsonfmt" ];
  };

  extraPackages = with pkgs; [
    vscode-langservers-extracted
    jsonfmt
  ];
}
