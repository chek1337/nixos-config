{
  flake.modules.homeManager.tmux-tmuxinator =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tmuxinator ];

      programs.zsh.shellAliases.tmor = "tmuxinator";

      xdg.configFile."tmuxinator/rice.yml".text = ''
        name: rice
        root: /etc/nixos

        windows:
          - editor:
              panes:
                - nvim /etc/nixos/configuration.nix
          - shell:
              panes:
                -
      '';

      xdg.configFile."tmuxinator/nixos-config-tmor.yml".text = ''
        name: nixos-config-tmor
        root: ~/nixos-config

        on_project_start: tmux set-option -g main-pane-width 70%

        windows:
          - main:
              layout: main-vertical
              panes:
                - nvim
                -
      '';
    };
}
