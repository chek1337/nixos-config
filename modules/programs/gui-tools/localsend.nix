{ ... }:
{
  flake.modules.homeManager.localsend =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.localsend ];
    };

  # LocalSend listens on 53317 (TCP for transfers, UDP for discovery).
  flake.modules.nixos.localsend = {
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
