{ ... }:
{
  flake.modules.homeManager.tldr =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tldr ];
    };
}
