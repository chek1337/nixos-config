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
        autoPrune.enable = true;
      };

      users.users.${username}.extraGroups = [ "docker" ];
    };

  flake.modules.homeManager.docker =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
        docker-compose
      ];
    };
}
