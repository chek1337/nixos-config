{ ... }:
{
  flake.modules.homeManager.pi-coding-agent =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.pi-coding-agent ];
    };
}
