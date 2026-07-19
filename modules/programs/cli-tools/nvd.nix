{ ... }:
{
  flake.modules.homeManager.nvd =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nvd ];
    };
}
