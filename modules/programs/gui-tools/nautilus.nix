{
  flake.modules.homeManager.nautilus =
    { pkgs, config, ... }:
    let
      terminal = config.home.sessionVariables.TERMINAL or "kitty";
    in
    {
      home.packages = with pkgs; [ nautilus ];

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

      xdg.mimeApps.defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
        "image/*" = "imv.desktop";
        "text/plain" = "nvim-terminal.desktop";
      };
    };
}
