{ inputs, ... }:
let
  schemes = {
    nord = import ./_schemes/nord.nix;
    catppuccin-mocha = import ./_schemes/catppuccin-mocha.nix;
    gruvbox-dark-hard = import ./_schemes/gruvbox-dark-hard.nix;
  };

  getScheme =
    pkgs: colorScheme:
    (schemes.${colorScheme} or schemes.nord) {
      self = inputs.self;
      inherit pkgs;
    };

  stylixCommon =
    { pkgs, config, ... }:
    let
      scheme = getScheme pkgs config.settings.colorScheme;
    in
    {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.settings.colorScheme}.yaml";
      image = scheme.image;
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
  flake.modules.nixos.themes =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];
      stylix = stylixCommon { inherit pkgs config; };
      fonts.packages = [ pkgs.noto-fonts-cjk-sans ];
      programs.dconf.enable = true;
    };

  flake.modules.homeManager.themes =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      scheme = getScheme pkgs config.settings.colorScheme;
    in
    {
      imports = [ inputs.stylix.homeModules.default ];
      programs.thunderbird = lib.mkIf config.programs.thunderbird.enable {
        profiles."default".extensions = [ scheme.thunderbird ];
      };
      stylix = (stylixCommon { inherit pkgs config; }) // {
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
