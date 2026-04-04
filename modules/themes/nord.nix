{ inputs, ... }:
let
  stylixBase =
    { pkgs, ... }:
    {
      enable = true;
      image = inputs.self + "/assets/nord2.png";
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
in
{
  flake.modules.nixos.nord =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = stylixBase { inherit pkgs; };
      fonts.packages = [ pkgs.noto-fonts-cjk-sans ];
    };

  flake.modules.homeManager.nord =
    { config, pkgs, ... }:
    {
      imports = [ inputs.stylix.homeModules.default ];
      stylix = (stylixBase { inherit pkgs; }) // {
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
