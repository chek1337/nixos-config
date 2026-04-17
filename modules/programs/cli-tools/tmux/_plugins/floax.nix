{
  pkgs,
  config,
  inputs,
}:
let
  floaxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-floax";
    rtpFilePath = "floax.tmux";
    version = "unstable";
    src = inputs.tmux-floax-fork;
  };
  floaxDir = "${floaxPlugin}/share/tmux-plugins/tmux-floax";
in
{
  plugin = floaxPlugin;
  extraConfig = ''
    set -g @floax-bind 'p'
    set -g @floax-bind-menu 'P'
    set -g @floax-width '80%'
    set -g @floax-height '80%'
    set -g @floax-border-color '${config.lib.stylix.colors.withHashtag.base0D}'
    set -g @floax-text-color '${config.lib.stylix.colors.withHashtag.base05}'
    set -g @floax-change-path 'false'
    set -g @floax-title 'PopupSession'
    set -g @floax-per-session 'true'
    # floax (русская раскладка)
    bind з run-shell "${floaxDir}/floax.sh"
    bind З run-shell "${floaxDir}/menu.sh"
  '';
}
