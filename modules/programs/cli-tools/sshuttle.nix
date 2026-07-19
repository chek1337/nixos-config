{ ... }:
{
  flake.modules.homeManager.sshuttle =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.sshuttle ];
    };
}
