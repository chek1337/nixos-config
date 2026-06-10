{ ... }:
{
  flake.modules.nixos.nix-corp-proxy =
    { config, lib, ... }:
    let
      proxyUrl = "http://proxy.eltex.loc:3128";
      noProxy = "127.0.0.1,localhost,.eltex.loc";
    in
    lib.mkIf config.settings.useEltexProxy {
      systemd.services.nix-daemon.environment = {
        http_proxy = proxyUrl;
        https_proxy = proxyUrl;
        no_proxy = noProxy;
      };

      nix.settings = {
        http-connections = lib.mkForce 50;
        connect-timeout = lib.mkForce 10;
      };
    };
}
