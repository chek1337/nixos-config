{
  flake.modules.homeManager.eza =
    { pkgs, ... }:
    let
      aliases = {
        l = "eza --grid --color=always --no-filesize --no-time --no-user --no-permissions --icons";
        ls = "eza --color=always --long --git --icons";
        lsa = "eza --color=always --long --git --icons -a -I .git";
        tree = "eza --color=always --long --git --icons --tree -I .git";
        treea = "eza --color=always --long --git --icons -a --tree -I .git";
      };
    in
    {
      home.packages = with pkgs; [ eza ];

      programs.zsh.shellAliases = aliases;
      programs.nushell.shellAliases = aliases;
    };
}
