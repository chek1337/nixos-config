{
  flake.modules.homeManager.sublime =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.sublime4 ];
    };
}
