{
  pkgs,
  inputs,
}:
let
  plugin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-copy-last-command";
    rtpFilePath = "copy-last-command.tmux";
    version = "unstable";
    src = inputs.tmux-copy-last-command;
    postInstall = ''
      cat > $target/copy-last-command.tmux <<'SH'
      #!/usr/bin/env bash
      CURRENT_DIR="$( cd "$( dirname "''${BASH_SOURCE[0]}" )" && pwd )"
      tmux source-file "$CURRENT_DIR/tmux.conf"
      SH
      chmod +x $target/copy-last-command.tmux
    '';
  };
in
{
  inherit plugin;
  extraConfig = ''
    # copy-last-command (русская раскладка)
    bind н if-shell -F '#{alternate_on}' \
      "display-message 'copy-last-command: unavailable in alternate screen'" \
      "copy-mode ; send-keys -X clear-selection ; send-keys -X previous-prompt ; send-keys -X begin-selection ; send-keys -X next-prompt ; send-keys -X cursor-up ; send-keys -X end-of-line ; send-keys -X copy-pipe-and-cancel ; run-shell -b 'tmux save-buffer - | tmux load-buffer -w -'"
    bind Н if-shell -F '#{alternate_on}' \
      "display-message 'copy-last-output: unavailable in alternate screen'" \
      "copy-mode ; send-keys -X clear-selection ; send-keys -X previous-prompt -o ; send-keys -X begin-selection ; send-keys -X next-prompt ; send-keys -X cursor-up ; send-keys -X end-of-line ; send-keys -X copy-pipe-and-cancel ; run-shell -b 'tmux save-buffer - | tmux load-buffer -w -'"
  '';
}
