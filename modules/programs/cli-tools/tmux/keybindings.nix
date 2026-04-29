{
  flake.modules.homeManager.tmux-keybindings =
    { ... }:
    {
      programs.tmux.extraConfig = ''
        # Навигация по панелям
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        # Навигация по панелям (русская раскладка)
        bind р select-pane -L
        bind о select-pane -D
        bind л select-pane -U
        bind д select-pane -R
        bind | split-window -h
        bind - split-window -v

        # Vi-like copy mode
        bind -T copy-mode-vi v   send -X begin-selection
        bind -T copy-mode-vi V   send -X select-line
        bind -T copy-mode-vi C-v send -X rectangle-toggle
        bind -T copy-mode-vi y   send -X copy-pipe "wl-copy"
        bind -T copy-mode-vi Y   send -X copy-end-of-line \; run "tmux save-buffer - | wl-copy"
        # Vi-like copy mode (русская раскладка)
        bind -T copy-mode-vi м   send -X begin-selection
        bind -T copy-mode-vi М   send -X select-line
        bind -T copy-mode-vi н   send -X copy-pipe "wl-copy"
        bind -T copy-mode-vi Н   send -X copy-end-of-line \; run "tmux save-buffer - | wl-copy"

        # Не выходить из copy-mode при отпускании мыши после выделения
        unbind -T copy-mode-vi MouseDragEnd1Pane

        unbind d
        bind D detach-client
        bind В detach-client

        # Окна (русская раскладка)
        bind с new-window
        bind т next-window
        bind ц choose-tree -Zw

        # Панели (русская раскладка)
        bind щ select-pane -t :.+
        bind й display-panes
        bind я resize-pane -Z
        bind ч confirm-before -p "kill-pane #P? (y/n)" kill-pane
        bind Ч confirm-before -p "kill-window #W? (y/n)" kill-window
        bind Х swap-pane -U
        bind Ъ swap-pane -D

        # Буфер / copy mode (русская раскладка)
        bind б copy-mode
        bind ъ paste-buffer

        # Разное (русская раскладка)
        bind к refresh-client
        bind ш display-message

        # https://ianthehenry.com/posts/tmux-copy-last-command/
        # Copy last command output (via OSC 133 shell integration)
        bind -n M-y {
          copy-mode
          send -X clear-selection
          send -X previous-prompt -o
          send -X begin-selection
          send -X next-prompt
          send -X cursor-up
          send -X end-of-line
          send -X copy-pipe-and-cancel "wl-copy"
        }

        # Navigate between command outputs in copy-mode.
        # Каждое нажатие M-k выделяет предыдущий вывод, M-j — следующий.
        # Из copy-mode штатно: y копирует выделение, Enter тоже по желанию.
        bind -n M-K {
          if -F '#{!=:#{pane_in_mode},1}' { copy-mode }
          send -X clear-selection
          send -X previous-prompt -o
          send -X begin-selection
          send -X next-prompt
          send -X cursor-up
          send -X end-of-line
          send -X other-end
        }
        bind -n M-J {
          if -F '#{!=:#{pane_in_mode},1}' { copy-mode }
          send -X clear-selection
          send -X next-prompt -o
          send -X begin-selection
          send -X next-prompt
          send -X cursor-up
          send -X end-of-line
          send -X other-end
        }
      '';
    };
}
