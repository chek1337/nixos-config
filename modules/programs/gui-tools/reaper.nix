{ ... }:
{
  flake.modules.homeManager.reaper =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # reaper.fm 302-redirects www -> dlcf (CloudFront); the Nix build
        # sandbox stalls on that redirect hop while the host network is fine.
        # Fetch the CDN URL directly so no redirect is involved. Same hash &
        # filename as upstream => same FOD store path. On a nixpkgs reaper
        # bump, update the URL + hash here (or drop this override).
        (reaper.overrideAttrs (_: {
          src = fetchurl {
            url = "https://dlcf.reaper.fm/7.x/reaper771_linux_x86_64.tar.xz";
            hash = "sha256-OozJHud6PMOkFU2wMmdOYS0PKfyaAV+HHhROJfSr0GM=";
          };
        }))
        guitarix
        neural-amp-modeler-lv2
        yabridge
        yabridgectl
        lsp-plugins
        calf
      ];
    };
}
