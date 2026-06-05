{ ... }:
{
  # Бесшовная навигация между сплитами nvim и панелями tmux.
  # Tmux-сторона: modules/programs/cli-tools/tmux/smart-splits.nix.
  # Плагин выставляет @pane-is-vim, по нему tmux решает, бросать ли клавишу
  # внутрь nvim или переключать панель сам.
  plugins.smart-splits = {
    enable = true;
    settings = {
      multiplexer_integration = "tmux";
      # На крае nvim-сплитов не wrap'ить, просто стоять (симметрия
      # с no-wrap в tmux/smart-splits.nix).
      at_edge = "stop";
    };
  };

  keymaps = [
    {
      key = "<C-S-h>";
      action.__raw = "function() require('smart-splits').move_cursor_left() end";
      options.desc = "Window/pane left";
    }
    {
      key = "<C-S-j>";
      action.__raw = "function() require('smart-splits').move_cursor_down() end";
      options.desc = "Window/pane down";
    }
    {
      key = "<C-S-k>";
      action.__raw = "function() require('smart-splits').move_cursor_up() end";
      options.desc = "Window/pane up";
    }
    {
      key = "<C-S-l>";
      action.__raw = "function() require('smart-splits').move_cursor_right() end";
      options.desc = "Window/pane right";
    }
  ];
}
