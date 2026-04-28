{ ... }:
{
  flake.modules.nixos.waydroid =
    { pkgs-stable, ... }:
    {
      virtualisation.waydroid.enable = true;
      virtualisation.waydroid.package = pkgs-stable.waydroid-nftables;

      environment.systemPackages = with pkgs-stable; [
        waydroid-helper
        wl-clipboard
        android-tools
      ];

      systemd = {
        packages = [ pkgs-stable.waydroid-helper ];
        services.waydroid-mount.wantedBy = [ "multi-user.target" ];
      };

      services.geoclue2.enable = true;
    };

  flake.modules.homeManager.waydroid =
    {
      pkgs,
      pkgs-stable,
      lib,
      ...
    }:
    let
      allowedPackages = [
        "com.android.vending" # Google Play Store
        "com.swiftsoft.anixartd"
      ];

      filterScript = pkgs.writeShellScript "waydroid-app-filter" ''
        APPS_DIR="$HOME/.local/share/applications"
        allowed=(${lib.concatStringsSep " " allowedPackages})

        for f in "$APPS_DIR"/waydroid.*.desktop; do
          [ -f "$f" ] || continue
          pkg="''${f##*/waydroid.}"
          pkg="''${pkg%.desktop}"

          show=false
          for a in "''${allowed[@]}"; do
            [ "$a" = "$pkg" ] && show=true && break
          done

          if $show; then
            ${pkgs.desktop-file-utils}/bin/desktop-file-edit \
              --set-key=NoDisplay --set-value=false "$f"
          else
            ${pkgs.desktop-file-utils}/bin/desktop-file-edit \
              --set-key=NoDisplay --set-value=true "$f"
          fi
        done
      '';
    in
    {
      home.activation.filterWaydroidApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${filterScript}
      '';

      programs.zsh.shellAliases = {
        waydroid-up = "sudo systemctl start waydroid-container.service";
        waydroid-down = "sudo systemctl stop waydroid-container.service";
        waydroid-status = "systemctl status waydroid-container.service";
        waydroid-restart = "sudo systemctl restart waydroid-container.service";

        waydroid-apps = ''
          (
          printf "%-8s %-30s %s\n" "VISIBLE" "NAME" "PACKAGE"
          printf "%-8s %-30s %s\n" "-------" "----" "-------"
          for f in ~/.local/share/applications/waydroid.*.desktop; do
            pkg="''${f##*/waydroid.}"; pkg="''${pkg%.desktop}"
            name=$(grep "^Name=" "$f" | head -1 | cut -d= -f2)
            nd=$(grep "^NoDisplay=" "$f" | head -1 | cut -d= -f2)
            [ "''${nd}" = "true" ] && visible="no" || visible="yes"
            printf "%-8s %-30s %s\n" "$visible" "$name" "$pkg"
          done
          )'';
      };
    };
}
