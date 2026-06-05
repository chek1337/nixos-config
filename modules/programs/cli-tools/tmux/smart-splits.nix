{
  flake.modules.homeManager.tmux-smart-splits =
    { ... }:
    {
      # Бесшовная навигация между панелями tmux и окнами nvim через
      # Ctrl+Shift+hjkl. Когда в активной панели крутится Neovim со
      # включённым smart-splits.nvim, плагин выставляет pane-local флаг
      # @pane-is-vim — tmux пробрасывает клавишу внутрь, иначе сам
      # переключает панель.
      # Nvim-сторона: nixvim/plugins/qol/smart-splits.nix.
      #
      # extended-keys нужен, чтобы tmux не схлопывал Ctrl+Shift+h
      # обратно в Ctrl+h (терминал должен поддерживать CSI u / kitty
      # keyboard protocol; kitty 0.46 поддерживает).
      programs.tmux.extraConfig = ''
        set -s extended-keys on
        set -as terminal-features '*:extkeys'

        # No-wrap: на крае tmux-сетки просто молчим (пустая ветка
        # вместо select-pane), а не прыгаем на противоположный край.
        bind-key -n C-S-h if -F '#{@pane-is-vim}' { send-keys C-S-h } { if -F '#{pane_at_left}'   ''' 'select-pane -L' }
        bind-key -n C-S-j if -F '#{@pane-is-vim}' { send-keys C-S-j } { if -F '#{pane_at_bottom}' ''' 'select-pane -D' }
        bind-key -n C-S-k if -F '#{@pane-is-vim}' { send-keys C-S-k } { if -F '#{pane_at_top}'    ''' 'select-pane -U' }
        bind-key -n C-S-l if -F '#{@pane-is-vim}' { send-keys C-S-l } { if -F '#{pane_at_right}'  ''' 'select-pane -R' }

        # Те же chord'ы в vi-copy-mode — без проверки на nvim, но
        # тоже без wrap.
        bind-key -T copy-mode-vi C-S-h if -F '#{pane_at_left}'   ''' 'select-pane -L'
        bind-key -T copy-mode-vi C-S-j if -F '#{pane_at_bottom}' ''' 'select-pane -D'
        bind-key -T copy-mode-vi C-S-k if -F '#{pane_at_top}'    ''' 'select-pane -U'
        bind-key -T copy-mode-vi C-S-l if -F '#{pane_at_right}'  ''' 'select-pane -R'
      '';
    };
}
