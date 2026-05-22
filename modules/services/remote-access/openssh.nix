{ ... }:
{
  flake.modules.nixos.remote-access-openssh =
    { lib, config, ... }:
    let
      cfg = config.settings;
    in
    lib.mkIf cfg.enableRemoteSsh {
      services.openssh = {
        enable = true;
        ports = [ cfg.remoteSshPort ];
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          X11Forwarding = false;
        };
      };

      users.users.${cfg.username}.openssh.authorizedKeys.keys = cfg.remoteSshAuthorizedKeys;
    };
}
