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
        distrobox
      ];

      users.users.${username}.extraGroups = [ "podman" ];
    };
}
