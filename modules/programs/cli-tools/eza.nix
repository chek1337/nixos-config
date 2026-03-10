{
  flake.modules.homeManager.eza =
    { pkgs, ... }:
    let
      aliases = {
        l = "eza --grid --color=always --no-filesize --no-time --no-user --no-permissions --icons always";
        ls = "eza --color=always --long --git --icons always";
        lsa = "eza --color=always --long --git --icons always -a -I .git";
        tree = "eza --color=always --long --git --icons always --tree -I .git";
        treea = "eza --color=always --long --git --icons always -a --tree -I .git";
      };
    in
    {
      home.packages = with pkgs; [ eza ];

      programs.zsh.shellAliases = aliases;
      programs.nushell.shellAliases = aliases;
    };
}
