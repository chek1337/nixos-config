{ pkgs }:
{
  plugin = pkgs.tmuxPlugins.fingers;
  extraConfig = ''
    set -g @fingers-key none
    set -g @fingers-jump-key none
    # Копируем подсвеченное в системный буфер, подбирая инструмент под сессию
    # (wl-copy под Wayland, xclip/xsel под X11) — как #{@clip} в keybindings.nix.
    set -g @fingers-main-action 'echo -n {} | if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then wl-copy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard -in; else xsel -ib; fi'
    set -g @fingers-pattern-word '\S+'
    set -g @fingers-pattern-line '.+'
    bind f switch-client -T fingers-mode
    bind F command-prompt "find-window -Z -- '%%'"
    bind f run -b "#{@fingers-cli} start #{pane_id} --mode jump --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff,word"
    bind J run -b "#{@fingers-cli} start #{pane_id} --patterns ip,uuid,sha,url,path,hex,kubernetes,git-status,git-status-branch,diff"
    # fingers (русская раскладка)
    bind а run -b "#{@fingers-cli} start #{pane_id} --mode jump --patterns ip,uuid,sha,digit,url,path,hex,kubernetes,git-status,git-status-branch,diff,word"
    bind А command-prompt "find-window -Z -- '%%'"
    bind О run -b "#{@fingers-cli} start #{pane_id} --patterns ip,uuid,sha,url,path,hex,kubernetes,git-status,git-status-branch,diff"
  '';
}
