{
  flake.modules.nixos.x11-compat =
    { pkgs, ... }:
    {
      # X server is kept enabled so that X11 clients (including apps from
      # rootful distrobox containers, e.g. cryptopro-distrobox) can connect
      # to XWayland while the primary session runs on Wayland (niri).
      services.xserver.enable = true;

      environment.systemPackages = with pkgs; [
        xorg.xhost
        xorg.xauth
      ];

      # Grant any local Unix-socket client access to XWayland on session
      # start. Covers every distrobox flavor (rootful/rootless/arbitrary
      # UID) without per-UID bookkeeping. Safe on a single-user host: the
      # X server does not listen on TCP, so this does not expose anything
      # off-machine.
      systemd.user.services.xhost-local = {
        description = "Grant XWayland access to all local Unix-socket clients";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.xorg.xhost}/bin/xhost +local:";
          ExecStop = "${pkgs.xorg.xhost}/bin/xhost -local:";
        };
      };
    };
}
