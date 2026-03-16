{ ... }:
{
  flake.modules.nixos.docker =
    { username, ... }:
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
