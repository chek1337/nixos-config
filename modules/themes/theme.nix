{ inputs, ... }:
let
  stylixBase =
    { pkgs, config, ... }:
    {
      enable = true;
      image = inputs.self + "/assets/nord2.png";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.settings.colorScheme}.yaml";
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
in
{
  flake.modules.nixos.theme =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = stylixBase { inherit pkgs config; };
      fonts.packages = [ pkgs.noto-fonts-cjk-sans ];
    };

  flake.modules.homeManager.theme =
    { config, pkgs, ... }:
    {
      imports = [ inputs.stylix.homeModules.default ];
      stylix = (stylixBase { inherit pkgs config; }) // {
        icons = {
          enable = true;
          package = pkgs.nordzy-icon-theme;
          dark = "Nordzy-dark";
          light = "Nordzy";
        };
        targets = {
          qt.enable = false;
          firefox.profileNames = [ "default" ]; # not working
          librewolf = {
            # not working
            enable = true;
            profileNames = [ "default" ];
          };
        };
      };
      gtk.gtk4.theme = config.gtk.theme;
    };
}
