{ ... }:
{
  flake.modules.nixos.remote-access-sunshine =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    lib.mkIf config.settings.enableRemoteDesktop {
      services.sunshine = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        capSysAdmin = true;
      };

      networking.firewall.allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 48010;
          to = 48010;
        }
      ];

      environment.systemPackages = [ pkgs.moonlight-qt ];
    };
}
