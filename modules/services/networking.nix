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
    # "cryptopro-vpn"
    # "cryptopro-distrobox"
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
    };

  flake.modules.homeManager.networking = {
    imports = map hmMod modules;
  };
}
