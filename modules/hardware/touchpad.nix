let
  # Same name + same content in both modules produces an identical store path,
  # so the sudo whitelist match the command niri spawns.
  toggleScript =
    pkgs-stable:
    pkgs-stable.writeShellScript "toggle-touchpad" ''
      INHIBITED=""
      for input in /sys/class/input/input*; do
        name=$(cat "$input/name" 2>/dev/null || true)
        echo "$name" | grep -qi touchpad || continue
        [ -f "$input/inhibited" ] && INHIBITED="$input/inhibited" && break
      done
      [ -z "$INHIBITED" ] && exit 1
      STATE=$(cat "$INHIBITED")
      if [ "$STATE" = "0" ]; then echo 1 > "$INHIBITED"; else echo 0 > "$INHIBITED"; fi
    '';
in
{
  flake.modules.nixos.touchpad =
    { config, pkgs-stable, ... }:
    {
      security.sudo.extraRules = [
        {
          users = [ config.settings.username ];
          commands = [
            {
              command = "${toggleScript pkgs-stable}";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };

  flake.modules.homeManager.touchpad =
    { pkgs-stable, ... }:
    {
      services.niri.extraBinds."Ctrl+Mod+F24 repeat=false" =
        ''spawn "sudo" "${toggleScript pkgs-stable}"'';
    };
}
