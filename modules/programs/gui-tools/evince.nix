{
  flake.modules.homeManager.evince =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.evince ];
    };
}
