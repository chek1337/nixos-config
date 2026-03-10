{ inputs, ... }:
{
  flake.modules.nixos.zapret =
    { ... }:
    {
      imports = [ inputs.zapret-discord-youtube.nixosModules.default ];

      services.zapret-discord-youtube = {
        enable = true;
        config = "general(ALT)";
        gameFilter = "udp";
      };
    };
}
