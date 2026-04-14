{ ... }:
{
  vim.utility.smart-splits = {
    enable = true;
    setupOpts.multiplexer_integration = false;
    # Отключаем встроенные keymaps — заменяем своими с ручным tmux fallback
    keymaps.move_cursor_left = null;
    keymaps.move_cursor_down = null;
    keymaps.move_cursor_up = null;
    keymaps.move_cursor_right = null;
    keymaps.move_cursor_previous = null;
  };
}
