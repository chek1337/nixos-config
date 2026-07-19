{ ... }:
{
  flake.modules.homeManager.httpie =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.httpie ];
    };
}
