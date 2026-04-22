{ inputs, config, ... }:
let
  nixosMods = config.flake.modules.nixos;
  hmMods = config.flake.modules.homeManager;
  submoduleNames = [
    "wireguard-wg-quick"
    "wireguard-netns-vpn"
    "wireguard-netns-bypass"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.nixos.wireguard =
    { config, pkgs, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      imports = pick nixosMods;

      sops.secrets.${wgName} = {
        sopsFile = inputs.self + "/secrets/${wgName}.conf";
        format = "binary";
      };

      networking.firewall.checkReversePath = "loose";

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
      };

      environment.systemPackages = with pkgs; [
        wireguard-tools
        iproute2
        iptables
      ];
    };

  flake.modules.homeManager.wireguard =
    { ... }:
    {
      imports = pick hmMods;
    };
}
