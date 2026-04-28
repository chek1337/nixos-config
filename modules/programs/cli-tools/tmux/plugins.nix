{ inputs, ... }:
{
  flake.modules.homeManager.tmux-plugins =
    { pkgs-stable, config, ... }:
    {
      programs.tmux.plugins = [
        (import ./_plugins/fingers.nix { inherit pkgs-stable; })
        (import ./_plugins/floax.nix { inherit pkgs-stable config inputs; })
        (import ./_plugins/catppuccin.nix { inherit pkgs-stable config; })
      ];
    };
}
