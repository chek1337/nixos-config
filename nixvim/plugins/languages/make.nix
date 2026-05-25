{ pkgs, config, ... }:
{
  plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
    make
  ];

  plugins.lint.lintersByFt.make = [ "checkmake" ];

  extraPackages = with pkgs; [
    checkmake
  ];
}
