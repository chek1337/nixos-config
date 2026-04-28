{
  flake.modules.homeManager.tmux-tmuxinator =
    { pkgs-stable, ... }:
    {
      home.packages = [ pkgs-stable.tmuxinator ];

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

      xdg.configFile."tmuxinator/nixos-config.yml".text = ''
        name: nixos-config
        root: ~/nixos-config

        windows:
          - shell:
              panes:
                -
          - editor:
              panes:
                - nvim
      '';
    };
}
