{ config, ... }:
let
  nixosMods = config.flake.modules.nixos;
  hmMods = config.flake.modules.homeManager;
  submoduleNames = [
    "wireguard-wg-quick"
    # "wireguard-netns-vpn"
    # "wireguard-netns-bypass"
  ];
  pick = mods: map (n: mods.${n}) submoduleNames;
in
{
  flake.modules.nixos.wireguard =
    { pkgs, ... }:
    {
      imports = pick nixosMods ++ [ nixosMods.unblock-wg-secrets ];

      # networking.firewall.checkReversePath = "loose";
      #
      # boot.kernel.sysctl = {
      #   "net.ipv4.ip_forward" = 1;
      # };

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
