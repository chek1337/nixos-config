{
  flake.modules.homeManager.trash-cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        trash-cli
      ];

      programs.zsh.shellAliases = {
        rm = "trash-put";
        rml = "trash-list";
        rme = "trash-empty";
        rmr = "trash-restore";
        rms = "du -sh ~/.local/share/Trash 2>/dev/null || echo 'Trash is empty'";
      };
    };
}
