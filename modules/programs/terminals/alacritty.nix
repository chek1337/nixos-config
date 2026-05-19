{
  flake.modules.nixos.alacritty =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.alacritty ];
    };

  flake.modules.homeManager.alacritty =
    { ... }:
    {
      programs.alacritty = {
        enable = true;
        package = null;
        settings = {
          window = {
            padding = {
              x = 8;
              y = 8;
            };
          };
        };
      };
    };
}
