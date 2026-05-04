{
  flake.modules.nixos.nautilus = {
    services.gvfs.enable = true;
  };

  flake.modules.homeManager.nautilus =
    { pkgs-stable, config, ... }:
    let
      terminal = config.home.sessionVariables.TERMINAL or "kitty";
    in
    {
      home.packages = [ pkgs-stable.nautilus ];

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
