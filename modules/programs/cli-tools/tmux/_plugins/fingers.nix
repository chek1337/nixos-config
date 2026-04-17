{ pkgs }:
{
  plugin = pkgs.tmuxPlugins.fingers;
  extraConfig = ''
    set -g @fingers-key none
    set -g @fingers-main-action 'echo -n {} | wl-copy'
    set -g @fingers-pattern-word '\S+'
    set -g @fingers-pattern-line '.+'
    bind f switch-client -T fingers-mode
    bind F command-prompt "find-window -Z -- '%%'"
    bind f run -b "#{@fingers-cli} start #{pane_id} --mode jump --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff,word"
    # fingers (русская раскладка)
    bind а run -b "#{@fingers-cli} start #{pane_id} --mode jump --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff,word"
    bind А command-prompt "find-window -Z -- '%%'"
  '';
}
