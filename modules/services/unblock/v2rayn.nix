{ config, ... }:
let
  nixosMods = config.flake.modules.nixos;
in
{
  flake.modules.nixos.v2rayn =
    { pkgs, ... }:
    {
      imports = [ nixosMods.unblock-vless-secret ];

      environment.systemPackages = [ pkgs.v2rayn ];
    };

  flake.modules.homeManager.v2rayn =
    { pkgs, ... }:
    {
      # Основной сценарий: сначала поднимается v2rayN (локальный прокси на
      # 127.0.0.1:10808), остальные программы запускаются уже после него.
      # Бинарь ставится NixOS-частью модуля, поэтому берём его из PATH.
      services.niri.spawnAtStartup = [ "v2rayN" ];

      xdg.dataFile = {
        "v2rayN/bin/xray/xray".source = "${pkgs.xray}/bin/xray";
        "v2rayN/bin/sing_box/sing-box".source = "${pkgs.sing-box}/bin/sing-box";
        "v2rayN/bin/geoip.dat".source = "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat";
        "v2rayN/bin/geosite.dat".source = "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat";
      };
    };
}
