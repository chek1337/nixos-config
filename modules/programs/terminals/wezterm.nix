{ ... }:
{
  flake.modules.homeManager.wezterm =
    { pkgs, ... }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "flowchartsman";
        repo = "wezterm";
        rev = "fe53678ac3e09e1a0a9b361f9833fb500193e462";
        hash = "sha256-VkaMFo5TCp9UCDGhdjRbeCgGwiv6U3eADzdm4qYN7Ww=";
        fetchSubmodules = true;
      };
      wezterm-cursor-trail = pkgs.wezterm.overrideAttrs (_: {
        inherit src;
        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = src.outPath + "/Cargo.lock";
          outputHashes = {
            "finl_unicode-1.3.0" = "sha256-38S6XH4hldbkb6NP+s7lXa/NR49PI0w3KYqd+jPHND0=";
            "xcb-imdkit-0.3.0" = "sha256-rP4oKkZ0aC4/5Jm8t5Ru7n3qLHw74/58A0Gt+sygQgU=";
          };
        };
      });
    in
    {
      home.packages = [ wezterm-cursor-trail ];

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
