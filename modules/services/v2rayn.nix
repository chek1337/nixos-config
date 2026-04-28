{ inputs, ... }:
{
  flake.modules.nixos.v2rayn =
    { config, pkgs-stable, ... }:
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };

      environment.systemPackages = [ pkgs-stable.v2rayn ];
    };

  flake.modules.homeManager.v2rayn =
    { pkgs-stable, ... }:
    {
      xdg.dataFile = {
        "v2rayN/bin/xray/xray".source = "${pkgs-stable.xray}/bin/xray";
        "v2rayN/bin/geoip.dat".source = "${pkgs-stable.v2ray-geoip}/share/v2ray/geoip.dat";
        "v2rayN/bin/geosite.dat".source =
          "${pkgs-stable.v2ray-domain-list-community}/share/v2ray/geosite.dat";
      };

      programs.zsh.shellAliases = {
        vless-show = "cat /run/secrets/vless-chumakov";
        vless-copy = "cat /run/secrets/vless-chumakov | wl-copy";
      };
    };
}
