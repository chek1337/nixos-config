{ ... }:
{
  flake.modules.homeManager.ripgrep =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ripgrep ];
    };
}
