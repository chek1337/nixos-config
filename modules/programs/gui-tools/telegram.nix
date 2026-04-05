{
  flake.modules.homeManager.telegram =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ ayugram-desktop ];
    };
}
