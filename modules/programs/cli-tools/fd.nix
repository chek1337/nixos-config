{ ... }:
{
  flake.modules.homeManager.fd =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fd ];
    };
}
