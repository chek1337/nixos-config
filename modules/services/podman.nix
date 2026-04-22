{ ... }:
{
  flake.modules.nixos.podman =
    { config, pkgs, ... }:
    let
      username = config.settings.username;
    in
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = false;
      };

      environment.systemPackages = with pkgs; [
        # distrobox enter --root mybox -- env TERM=xterm-256color zsh
        distrobox
      ];

      users.users.${username}.extraGroups = [ "podman" ];
    };
}
