{ inputs, ... }:
{
  flake.modules.nixos.v2rayn =
    { config, pkgs, ... }:
    {
      sops.secrets."vless-chumakov" = {
        sopsFile = inputs.self + "/secrets/secrets.yaml";
        key = "vless-chumakov";
        owner = config.settings.username;
      };

      environment.systemPackages = [ pkgs.v2rayn ];
    };

  flake.modules.homeManager.v2rayn =
    { pkgs, ... }:
    {
      xdg.dataFile = {
        "v2rayN/bin/xray/xray".source = "${pkgs.xray}/bin/xray";
        "v2rayN/bin/geoip.dat".source = "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat";
        "v2rayN/bin/geosite.dat".source = "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat";
      };

      programs.zsh.shellAliases = {
        vless-show = "cat /run/secrets/vless-chumakov";
        vless-copy = "cat /run/secrets/vless-chumakov | wl-copy";
      };
    };
}
