{
  flake.modules.nixos.nautilus =
    { pkgs, ... }:
    {
      services.gvfs.enable = true;
      environment.systemPackages = [ pkgs.nautilus ];
      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "kitty";
      };
    };

  flake.modules.homeManager.nautilus =
    { pkgs, config, ... }:
    let
      terminal = config.home.sessionVariables.TERMINAL or "kitty";
    in
    {
      home.packages = [
        pkgs.file-roller
        pkgs.p7zip
        pkgs.unrar
        pkgs.unzip
        pkgs.zstd
      ];

      # Keybinding broken on Nautilus 49.x — upstream bug
      # https://github.com/Stunkymonkey/nautilus-open-any-terminal/issues/277
      # Right-click → "Open in kitty" works; Ctrl+Alt+T does not fire.
      dconf.settings."com/github/stunkymonkey/nautilus-open-any-terminal" = {
        new-tab = false;
        keybindings = "<Primary><Alt>t";
      };

      xdg.desktopEntries.nvim = {
        name = "Neovim wrapper";
        exec = "nvim %F";
        terminal = true;
        noDisplay = true;
        type = "Application";
      };

      programs.zsh.initContent = ''
        open() { nautilus "''${1:-.}" > /dev/null 2>&1 & disown }
      '';

      xdg.desktopEntries.nvim-terminal = {
        name = "Neovim";
        exec = "${terminal} -e nvim %F";
        icon = "nvim";
        terminal = false;
        mimeType = [
          "text/plain"
          "text/x-script"
          "application/x-shellscript"
          "text/x-c"
          "text/x-csrc"
          "text/x-chdr"
          "text/x-c++"
          "text/x-c++src"
          "text/x-c++hdr"
          "text/x-makefile"
          "text/x-python"
          "text/x-nix"
        ];
        categories = [
          "Utility"
          "TextEditor"
        ];
      };

    };
}
