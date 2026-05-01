{ inputs, ... }:
{
  flake.modules.nixos.zapret =
    { lib, ... }:
    {
      imports = [ inputs.zapret-discord-youtube.nixosModules.default ];

      services.zapret-discord-youtube = {
        enable = true;
        configName = "general(ALT)";
        gameFilter = "udp";
      };

      systemd.services.zapret-discord-youtube.wantedBy = lib.mkForce [ ];
    };

  flake.modules.homeManager.zapret =
    { ... }:
    {
      programs.zsh.shellAliases = {
        zapret-up = "sudo systemctl start zapret-discord-youtube.service";
        zapret-down = "sudo systemctl stop zapret-discord-youtube.service";
        zapret-status = "sudo systemctl status zapret-discord-youtube.service";
        zapret-restart = "sudo systemctl restart zapret-discord-youtube.service";
      };
    };
}
