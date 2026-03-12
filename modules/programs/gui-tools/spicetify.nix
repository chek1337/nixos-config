{ inputs, ... }:
{
  flake.modules.homeManager.spicetify =
    { pkgs, ... }:
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];
      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
        in
        {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblockify
            hidePodcasts
            shuffle
            keyboardShortcut
            fullAppDisplay
            volumePercentage
            skipStats
            playlistIcons
          ];
        };
      services.gnome.gnome-keyring.enable = true;
    };
}
