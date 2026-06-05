{ ... }:
{
  # Бесшовная навигация между сплитами nvim и панелями tmux.
  # Tmux-сторона: modules/programs/cli-tools/tmux/smart-splits.nix.
  # Плагин выставляет @pane-is-vim, по нему tmux решает, бросать ли клавишу
  # внутрь nvim или переключать панель сам.
  plugins.smart-splits = {
    enable = true;
    settings.multiplexer_integration = "tmux";
  };

  keymaps = [
    {
      key = "<C-h>";
      action.__raw = "function() require('smart-splits').move_cursor_left() end";
      options.desc = "Window/pane left";
    }
    {
      key = "<C-j>";
      action.__raw = "function() require('smart-splits').move_cursor_down() end";
      options.desc = "Window/pane down";
    }
    {
      key = "<C-k>";
      action.__raw = "function() require('smart-splits').move_cursor_up() end";
      options.desc = "Window/pane up";
    }
    {
      key = "<C-l>";
      action.__raw = "function() require('smart-splits').move_cursor_right() end";
      options.desc = "Window/pane right";
    }
  ];
}
