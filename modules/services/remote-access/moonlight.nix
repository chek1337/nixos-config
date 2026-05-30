{ ... }:
{
  flake.modules.nixos.remote-access-moonlight =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    lib.mkIf config.settings.enableMoonlightClient {
      environment.systemPackages = [ pkgs.moonlight-qt ];
    };
}
