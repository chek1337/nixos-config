{ ... }:
{
  flake.modules.homeManager.wezterm =
    { pkgs-stable, ... }:
    let
      src = pkgs-stable.fetchFromGitHub {
        owner = "flowchartsman";
        repo = "wezterm";
        rev = "fe53678ac3e09e1a0a9b361f9833fb500193e462";
        hash = "sha256-VkaMFo5TCp9UCDGhdjRbeCgGwiv6U3eADzdm4qYN7Ww=";
        fetchSubmodules = true;
      };
      wezterm-cursor-trail = pkgs-stable.wezterm.overrideAttrs (_: {
        inherit src;
        cargoDeps = pkgs-stable.rustPlatform.importCargoLock {
          lockFile = src.outPath + "/Cargo.lock";
          outputHashes = {
            "finl_unicode-1.3.0" = "sha256-38S6XH4hldbkb6NP+s7lXa/NR49PI0w3KYqd+jPHND0=";
            "xcb-imdkit-0.3.0" = "sha256-rP4oKkZ0aC4/5Jm8t5Ru7n3qLHw74/58A0Gt+sygQgU=";
          };
        };
      });
    in
    {
      programs.wezterm = {
        enable = true;
        package = wezterm-cursor-trail;
        extraConfig = ''
          local config = {}
          config.cursor_trail = {
            enabled = true,
            dwell_threshold = 50,
            distance_threshold = 2,
            duration = 100,
            spread = 4.0,
            opacity = 0.8,
          }
          config.animation_fps = 60
          return config
        '';
      };
    };
}
