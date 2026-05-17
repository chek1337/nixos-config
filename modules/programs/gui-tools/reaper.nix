{ ... }:
{
  flake.modules.homeManager.reaper =
    { pkgs, ... }:
    {
      programs.zsh.shellAliases = {
        pw-buf-64 = "pw-metadata -n settings 0 clock.force-quantum 64";
        pw-buf-128 = "pw-metadata -n settings 0 clock.force-quantum 128";
        pw-buf-256 = "pw-metadata -n settings 0 clock.force-quantum 256";
        pw-buf-512 = "pw-metadata -n settings 0 clock.force-quantum 512";
        pw-buf-1024 = "pw-metadata -n settings 0 clock.force-quantum 1024";
        pw-buf-auto = "pw-metadata -n settings 0 clock.force-quantum 0";
        pw-buf = "pw-metadata -n settings | grep quantum";
      };

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
