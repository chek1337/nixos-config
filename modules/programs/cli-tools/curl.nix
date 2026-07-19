{ ... }:
{
  flake.modules.homeManager.curl =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.curl ];
    };
}
