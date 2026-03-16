{
  flake.modules.homeManager.w3m =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ w3m ];
    };
}
