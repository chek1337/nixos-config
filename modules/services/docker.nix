{ ... }:
{
  flake.modules.nixos.docker =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      virtualisation.docker = {
        enable = true;

        daemon.settings = {
          "insecure-registries" = [
            "localhost:8082"
            "nexus:8082"
          ];
        };
      };

      networking.hosts."127.0.0.1" = [ "nexus" ];

      users.users.${username}.extraGroups = [ "docker" ];
    };

  flake.modules.homeManager.docker =
    { pkgs-stable, ... }:
    {
      home.packages = with pkgs-stable; [
        docker
        docker-compose
      ];
    };
}
