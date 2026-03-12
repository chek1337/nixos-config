{ inputs, pkgs, ... }:
{
  flake.modules.nixos.nord =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = {
        enable = true;
        image = inputs.self + "/assets/nord.jpg";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
          sizes = {
            terminal = 10;
            applications = 10;
          };
        };
        cursor = {
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 16;
        };
      };
    };

  flake.modules.homeManager.nord =
    { ... }:
    {
      stylix.targets.firefox.profileNames = [ "default" ];
    };
}
