{ ... }:
{
  flake.modules.nixos.reaper =
    { config, ... }:
    let
      username = config.settings.username;
    in
    {
      users.users.${username}.extraGroups = [ "audio" ];
      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "soft";
          value = "99999";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "524288";
        }
      ];
      services.pipewire.extraConfig.pipewire."10-quantum-512" = {
        "context.properties"."default.clock.quantum" = 512;
      };
    };

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
        # The Nix build sandbox in this network cannot pull reaper.fm /
        # dlcf.reaper.fm (CloudFront): TCP connects but data transfer hangs
        # at 0 bytes. Host curl/nix-prefetch-url work; GitHub works from the
        # sandbox too. reaper's src FOD is NOT on cache.nixos.org (unfree,
        # not built by Hydra), so every fresh install must fetch upstream and
        # then stalls. Mirror the tarball on this repo's GitHub release and
        # fetch from there. `name` is deliberately distinct from nixpkgs'
        # `reaper771_linux_x86_64.tar.xz` so the FOD store path can't collide
        # with the stalling upstream src .drv (Nix would otherwise be free to
        # realize the shared path via either). On a nixpkgs reaper bump:
        # upload the new tarball to the `reaper-vendor` release and update
        # the URL + hash here.
        (reaper.overrideAttrs (_: {
          src = fetchurl {
            name = "reaper771-vendored.tar.xz";
            url = "https://github.com/chek1337/nixos-config/releases/download/reaper-vendor/reaper771_linux_x86_64.tar.xz";
            hash = "sha256-OozJHud6PMOkFU2wMmdOYS0PKfyaAV+HHhROJfSr0GM=";
          };
        }))
        guitarix
        neural-amp-modeler-lv2
        # Windows VST bridge. To install a .exe plugin:
        #   1. winetricks mfc42  (once, if installer needs MFC)
        #   2. wine "Setup Plugin.exe"
        #   3. yabridgectl add ~/.wine/drive_c/Program\ Files/Common\ Files/VST3/<Vendor>
        #   4. yabridgectl sync
        #   5. Reaper → Options → Preferences → Plug-ins → VST → Re-scan
        yabridge
        yabridgectl
        lsp-plugins
        calf
      ];
    };
}

# Neural DSP - Darkglass Ultra v3.0.0 VST/VST3/AAX(MODiFiED) x64 R2R [01.01.2021]
# https://rutracker.net/forum/viewtopic.php?t=5990900
# magnet:?xt=urn:btih:AF9D88C42AF24CE35D756EC0C94FE3D9BBC23C31&tr=http%3A%2F%2Fbt2.t-ru.org%2Fann%3Fmagnet&dn=Neural%20DSP%20-%20Darkglass%20Ultra%20v3.0.0%20VST%2FVST3%2FAAX(MODiFiED)%20x64%20R2R%20%5B01.01.2021%5D

# Ampeg & Line 6 - SVT Suite 1.0 + Helix Native 3.10 VST, VST3, AAX x64 [05.2021]
# https://rutracker.net/forum/viewtopic.php?t=6059182
# magnet:?xt=urn:btih:D9F0D1F3BD75864C9D4AA0AEA40D0AB4CE6110BE&tr=http%3A%2F%2Fbt3.t-ru.org%2Fann%3Fmagnet&dn=Ampeg%20%26%20Line%206%20-%20SVT%20Suite%201.0%20%2B%20Helix%20Native%203.10%20VST%2C%20VST3%2C%20AAX%20x64%20%5B05.2021%5D
