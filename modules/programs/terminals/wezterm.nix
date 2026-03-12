{ ... }:
{
  flake.modules.homeManager.wezterm =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.wezterm.overrideAttrs (_: {
          src = pkgs.fetchFromGitHub {
            owner = "flowchartsman";
            repo = "wezterm";
            rev = "fe53678ac3e09e1a0a9b361f9833fb500193e462";
            hash = "sha256-VkaMFo5TCp9UCDGhdjRbeCgGwiv6U3eADzdm4qYN7Ww=";
            fetchSubmodules = true;
          };
        }))
      ];

      xdg.configFile."wezterm/wezterm.lua".text = ''
        local config = {}

        config.cursor_trail = {
          enabled = true,
          dwell_threshold = 80,
          distance_threshold = 5,
          duration = 300,
          spread = 2,
          opacity = 0.6,
        }
        config.animation_fps = 60

        return config
      '';
    };
}
