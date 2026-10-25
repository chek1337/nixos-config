{ ... }:
{
  flake.modules.homeManager.tuios =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;

      # Тема tuios из активной base16-палитры Stylix. ANSI-слоты раскладываем
      # так же, как stylix делает для терминалов (kitty и т.п.), а `chrome` —
      # цвета самого tuios (рамки, dock, пиллы режимов) — в те же роли, что и
      # у tmux в tmux/theme.nix: акцент base0D, выделение base0A.
      theme = {
        id = "stylix";
        display_name = "Stylix";
        fg = c.base05;
        bg = c.base00;
        cursor = c.base05;

        black = c.base00;
        red = c.base08;
        green = c.base0B;
        yellow = c.base0A;
        blue = c.base0D;
        purple = c.base0E;
        cyan = c.base0C;
        white = c.base05;

        bright_black = c.base03;
        bright_red = c.base08;
        bright_green = c.base0B;
        bright_yellow = c.base0A;
        bright_blue = c.base0D;
        bright_purple = c.base0E;
        bright_cyan = c.base0C;
        bright_white = c.base07;

        chrome = {
          accent = c.base0D;
          accent_bright = c.base0C;
          success = c.base0B;
          warning = c.base0A;
          error = c.base08;
          info = c.base0D;
          surface = c.base01;
        };
      };
    in
    {
      home.packages = [ pkgs.tuios ];

      xdg.configFile."tuios/themes/stylix.json".text = builtins.toJSON theme;

      # Кеймап tuios под мою tmux-мышечную память (см. tmux/{core,keybindings}.nix).
      # База — встроенный preset "tmux": окно tmux = workspace tuios, панель
      # tmux = window tuios. Поверх него перебиваем только то, что у меня в tmux
      # отличается от дефолтов.
      #
      # Русских дублей нет намеренно: под kitty keyboard protocol tuios сам
      # сопоставляет кириллическую клавишу с US-клавишей на той же позиции.
      #
      # Файл — read-only симлинк в /nix/store: менеджер биндов и
      # настройки внутри tuios не смогут его переписать. force = true — на случай,
      # если tuios уже успел положить сюда свой config.toml.
      xdg.configFile."tuios/config.toml".force = true;
      xdg.configFile."tuios/config.toml".text = ''
        [startup]
        tiled = true
        daemon = true

        [appearance]
        theme = "stylix"
        preferred_shell = "${pkgs.zsh}/bin/zsh"
        scrollback_lines = 10000
        # status-position top
        dockbar_position = "top"
        border_style = "rounded"

        [keybindings]
        preset = "tmux"
        leader_key = "ctrl+space"
        # Аналог bind -r. В tmux у меня это отдельные key table'ы (move/resize/
        # window-move), в tuios таких нет — вместо них repeat: после префикса
        # клавиши ниже можно жать подряд. Навигация h/j/k/l сюда не входит, как
        # и в tmux, чтобы буква сразу после неё ушла в шелл.
        repeat = [
          "resize_pane_left_5", "resize_pane_right_5", "resize_pane_up_5", "resize_pane_down_5",
          "swap_left", "swap_down", "swap_up", "swap_right",
          "move_workspace_left", "move_workspace_right",
        ]

        # Не забираем у панелей ctrl+p (nvim, история) и alt+space; палитра
        # остаётся на prefix+: и prefix+P.
        [keybindings.global]
        command_palette = []
        launcher = []

        # В tmux у меня нет root-биндов на alt+стрелки и alt+n/p — отдаём их
        # обратно шеллу (alt+left/right — слово влево/вправо в zsh).
        [keybindings.terminal_mode]
        terminal_focus_left = []
        terminal_focus_down = []
        terminal_focus_up = []
        terminal_focus_right = []
        terminal_next_window = []
        terminal_prev_window = []

        [keybindings.prefix_mode]
        # Навигация по панелям: prefix + h/j/k/l.
        terminal_focus_left = ["h", "left"]
        terminal_focus_down = ["j", "down"]
        terminal_focus_up = ["k", "up"]
        terminal_focus_right = ["l", "right"]

        # Вместо «move mode» (prefix+m, затем hjkl): prefix + H/J/K/L с repeat.
        swap_left = ["H"]
        swap_down = ["J"]
        swap_up = ["K"]
        swap_right = ["L"]

        # Вместо «resize mode» (prefix+r, затем hjkl): prefix + ctrl+h/j/k/l с repeat.
        resize_pane_left_5 = ["ctrl+h", "ctrl+left"]
        resize_pane_down_5 = ["ctrl+j", "ctrl+down"]
        resize_pane_up_5 = ["ctrl+k", "ctrl+up"]
        resize_pane_right_5 = ["ctrl+l", "ctrl+right"]
        reload_config = []

        # Вместо «window-move mode» (prefix+M, затем h/l): prefix + < / > с repeat.
        move_workspace_left = ["<"]
        move_workspace_right = [">"]

        # L в preset — last_session, но у меня L занят swap'ом; l (last_workspace)
        # — навигацией. last_session переезжает на ctrl+o.
        last_workspace = []
        last_session = ["ctrl+o"]

        # detach на D (в tmux: unbind d; bind D detach-client).
        prefix_detach = ["D"]
        prefix_debug = []

        # X — закрыть окно tmux (= workspace tuios) с подтверждением.
        close_workspace = ["X", "&"]
        prefix_close_session = []

        # p — плавающий scratch-терминал, как floax в tmux.
        toggle_scratch = ["p"]
        prev_workspace = []

        # f — хинты (tmux-fingers), F — поиск панели (find-window).
        hints = ["f"]
        choose_tree = ["F", "/"]
      '';
    };
}
