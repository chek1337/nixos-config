{ ... }:
{
  flake.modules.nixos.docker =
    { ... }:
    {
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
      };

      users.users.chek.extraGroups = [ "docker" ];
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
