{ ... }:
{
  flake.modules.homeManager.gnumake =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gnumake ];
    };
}
