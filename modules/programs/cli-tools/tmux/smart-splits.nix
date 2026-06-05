{
  flake.modules.homeManager.tmux-smart-splits =
    { ... }:
    {
      # Бесшовная навигация между панелями tmux и окнами nvim через C-hjkl.
      # Когда в активной панели крутится Neovim со включённым smart-splits.nvim,
      # плагин выставляет pane-local флаг @pane-is-vim — tmux пробрасывает
      # клавишу внутрь, иначе сам переключает панель.
      # Nvim-сторона: nixvim/plugins/qol/smart-splits.nix.
      programs.tmux.extraConfig = ''
        bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h' 'select-pane -L'
        bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j' 'select-pane -D'
        bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k' 'select-pane -U'
        bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l' 'select-pane -R'

        # Те же hjkl в vi-copy-mode — без проверки на nvim, copy-mode свой.
        bind-key -T copy-mode-vi C-h select-pane -L
        bind-key -T copy-mode-vi C-j select-pane -D
        bind-key -T copy-mode-vi C-k select-pane -U
        bind-key -T copy-mode-vi C-l select-pane -R
      '';
    };
}
