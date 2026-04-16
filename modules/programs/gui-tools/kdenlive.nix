{
  flake.modules.homeManager.kdenlive =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ kdePackages.kdenlive ];
      # stylix.targets.kdenlive.enable = false;
    };
}
