{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "wireguard"
    "wireproxy"
    "zapret"
    "vopono"
    "throne"
    "v2rayn"
    "tun2proxy"
  ];
in
{
  flake.modules.nixos.networking =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      imports = map nixosMod modules;

      networking.networkmanager.enable = true;
      users.users.${username}.extraGroups = [ "networkmanager" ];

      services.resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

  flake.modules.homeManager.networking = {
    imports = map hmMod modules;
  };
}
