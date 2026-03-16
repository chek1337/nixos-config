{
  flake.modules.homeManager.browsh =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ browsh ];
    };
}
