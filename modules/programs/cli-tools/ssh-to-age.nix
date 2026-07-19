{ ... }:
{
  flake.modules.homeManager.ssh-to-age =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.ssh-to-age ];
    };
}
