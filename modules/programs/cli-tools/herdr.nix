{ ... }:
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.herdr ];

      # Кеймап herdr под мою tmux-мышечную память. herdr — prefix-мультиплексор
      # в стиле tmux, конфиг живёт в $XDG_CONFIG_HOME/herdr/config.toml и частичный
      # [keys] мёржится с встроенными дефолтами. Указываю только то, что отличается
      # от дефолта herdr либо что хочу зафиксировать явно; прочие поля наследуют
      # встроенные значения. Соответствие tmux см. modules/.../tmux/{core,keybindings}.nix.
      xdg.configFile."herdr/config.toml".text = ''
        [keys]
        # Префикс как в tmux (core.nix): Ctrl+Space вместо herdr-дефолта Ctrl+B.
        prefix = "ctrl+space"

        # Панели: h/j/k/l — навигация (совпадает и с tmux, и с дефолтом herdr).
        focus_pane_left = "prefix+h"
        focus_pane_down = "prefix+j"
        focus_pane_up = "prefix+k"
        focus_pane_right = "prefix+l"

        # Перемещение (swap) панелей: shift+h/j/k/l. В tmux это режим `prefix+m`;
        # у herdr отдельного режима нет, есть прямые swap-бинды — кладу их на shift.
        swap_pane_left = "prefix+shift+h"
        swap_pane_down = "prefix+shift+j"
        swap_pane_up = "prefix+shift+k"
        swap_pane_right = "prefix+shift+l"

        # Сплиты как в tmux: `|` — вбок (vertical/side-by-side), `-` — вниз (stacked).
        split_vertical = "prefix+|"
        split_horizontal = "prefix+minus"

        # Режим изменения размера — `prefix+r`, как режим resize в tmux.
        resize_mode = "prefix+r"

        # Copy-mode, зум, закрытие панели — дефолты tmux, совпадают с herdr.
        copy_mode = "prefix+["
        zoom = "prefix+z"
        close_pane = "prefix+x"

        # Вкладки herdr ≈ окна tmux: c — новая, n/p — вперёд/назад.
        new_tab = "prefix+c"
        next_tab = "prefix+n"
        previous_tab = "prefix+p"

        # Detach на `prefix+shift+d` (в tmux я перебиндил detach с d на D).
        # Это освобождает дефолтный shift+d из-под close_workspace — переношу его
        # на shift+q, иначе herdr отключит вторую команду на том же аккорде.
        detach = "prefix+shift+d"
        close_workspace = "prefix+shift+q"
      '';
    };
}
