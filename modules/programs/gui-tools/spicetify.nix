{ inputs, ... }:
{
  flake.modules.homeManager.spicetify =
    { pkgs-unstable, ... }:
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];
      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs-unstable.stdenv.hostPlatform.system};
        in
        {
          enable = true;
          spotifyLaunchFlags = "--password-store=basic";
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
    };
}
