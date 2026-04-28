{ inputs, ... }:
let
  schemes = {
    nord = import ./_schemes/nord.nix;
    catppuccin-mocha = import ./_schemes/catppuccin-mocha.nix;
    gruvbox-dark-hard = import ./_schemes/gruvbox-dark-hard.nix;
  };

  getScheme =
    pkgs-unstable: colorScheme:
    (schemes.${colorScheme} or schemes.nord) {
      self = inputs.self;
      inherit pkgs-unstable;
    };

  stylixCommon =
    { pkgs-unstable, config, ... }:
    let
      scheme = getScheme pkgs-unstable config.settings.colorScheme;
    in
    {
      enable = true;
      base16Scheme = "${pkgs-unstable.base16-schemes}/share/themes/${config.settings.colorScheme}.yaml";
      image = scheme.image;
      fonts = {
        monospace = {
          package = pkgs-unstable.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs-unstable.inter;
          name = "Inter";
        };
        sizes = {
          terminal = 10;
          applications = 10;
        };
      };
      cursor = {
        package = pkgs-unstable.adwaita-icon-theme;
        name = "Adwaita";
        size = 16;
      };
    };
in
{
  flake.modules.nixos.themes =
    { pkgs-unstable, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = stylixCommon { inherit pkgs-unstable config; };
      fonts.packages = [ pkgs-unstable.noto-fonts-cjk-sans ];
      programs.dconf.enable = true;
    };

  flake.modules.homeManager.themes =
    {
      config,
      pkgs-unstable,
      lib,
      ...
    }:
    let
      scheme = getScheme pkgs-unstable config.settings.colorScheme;
    in
    {
      imports = [ inputs.stylix.homeModules.default ];
      programs.thunderbird = lib.mkIf config.programs.thunderbird.enable {
        profiles."default".extensions = [ scheme.thunderbird ];
      };
      stylix = (stylixCommon { inherit pkgs-unstable config; }) // {
        icons = {
          enable = true;
          inherit (scheme.icons) package dark light;
        };
        targets = {
          qt.enable = false;
        };
      };
      gtk.gtk4.theme = config.gtk.theme;
    };
}
