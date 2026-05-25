{ pkgs, config, ... }:
{
  plugins.lsp.servers.nixd.enable = true;

  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    nix
  ];

  plugins.conform-nvim.settings.formatters_by_ft.nix = [ "nixfmt" ];

  plugins.lint.lintersByFt.nix = [
    "statix"
    "deadnix"
  ];

  extraPackages = with pkgs; [
    nixd
    nixfmt
    statix
    deadnix
  ];
}
