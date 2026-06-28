{ ... }:
{
  flake.modules.homeManager.herdr =
    { config, pkgs, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;

      # Полярность активной схемы. herdr [theme].name выбирает базовую палитру
      # из 16 встроенных токенов; ниже мы переопределяем ВСЕ 16 через
      # [theme.custom], так что база нужна лишь как осмысленный fallback/label
      # и для light/dark-полярности там, где herdr ещё не спросил конкретный
      # токен. Таблица повторяет схемы из hunk.nix (modules/.../hunk.nix);
      # незнакомая схема считается тёмной.
      darkScheme = {
        nord = true;
        catppuccin-mocha = true;
        gruvbox-dark-hard = true;
        ilyasyoy-monochrome-dark = true;
        ilyasyoy-monochrome-light = false;
      };
      dark = darkScheme.${config.settings.colorScheme} or true;
      baseName = if dark then "catppuccin" else "catppuccin-latte";
    in
    {
      home.packages = [ pkgs.herdr ];

      # Кеймап herdr под мою tmux-мышечную память. herdr — prefix-мультиплексор
      # в стиле tmux, конфиг живёт в $XDG_CONFIG_HOME/herdr/config.toml и частичный
      # [keys] мёржится с встроенными дефолтами. Указываю только то, что отличается
      # от дефолта herdr либо что хочу зафиксировать явно; прочие поля наследуют
      # встроенные значения. Соответствие tmux см. modules/.../tmux/{core,keybindings}.nix.
      #
      # Нюанс: herdr использует этот же файл как изменяемое состояние и пишет в него
      # напрямую (onboarding, тема, ui-тоглы) через fs::write по пути. Здесь файл —
      # read-only симлинк в /nix/store, поэтому такие записи herdr'а будут падать
      # (он лишь покажет тост на 5с). Это осознанный декларативный компромисс: nix —
      # единственный источник правды. Поэтому:
      #   * onboarding = false — гасим онбординг заранее, иначе herdr попытается
      #     записать его при первом запуске и будет показывать экран каждый раз;
      #   * force = true — herdr (или его прошлый запуск) уже клал сюда реальный файл,
      #     из-за чего активация HM падала «в пути»; force разрешает HM затирать его.
      xdg.configFile."herdr/config.toml".force = true;
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        # Тема herdr из активной base16-палитры Stylix (config.settings.colorScheme),
        # тот же источник правды, что и для hunk/rice/прочего. herdr держит палитру
        # в 16 токенах (src/app/state.rs Palette); base16 ложится на них почти 1:1,
        # поэтому переопределяем каждый токен напрямую — без блендов, в отличие от
        # hunk (там нужен был tint поверх Shiki-темы; у herdr синтакс-темы нет).
        #
        # Замечание про write-back: herdr пишет выбор темы/ui-тоглы в этот же файл
        # через fs::write. Файл — read-only симлинк в /nix/store (см. комментарий
        # к force=true ниже), поэтому ручной выбор темы в Settings будет падать
        # тостом и не переживёт перезапуск — палитра зафиксирована декларативно.
        [theme]
        name = "${baseName}"

        [theme.custom]
        # Серая шкала: panel_bg (самый тёмный фон) → text (основной текст),
        # ровно ложится на base00..base05.
        panel_bg = "${c.base00}"      # фон панелей/оверлеев/модалок
        surface_dim = "${c.base01}"   # очень тусклый фон под разделители
        surface0 = "${c.base02}"      # фон выбранного/сфокусированного
        surface1 = "${c.base03}"      # фон hover/active (чуть светлее)
        overlay0 = "${c.base03}"      # приглушённый текст (вторичное, номера)
        overlay1 = "${c.base04}"      # чуть ярче приглушённого
        subtext0 = "${c.base04}"      # тусклые подписи (номера воркспейсов)
        text = "${c.base05}"          # основной текст

        # Акцент и семантические цвета статусов агентов/уведомлений.
        accent = "${c.base0D}"        # акцент: подсветка, активные рамки (blue)
        blue = "${c.base0D}"          # уведомления / unseen-маркеры
        mauve = "${c.base0E}"         # имя ветки / спец-метка (purple)
        green = "${c.base0B}"         # done / idle
        yellow = "${c.base0A}"        # working / running
        red = "${c.base08}"           # needs attention / blocked
        teal = "${c.base0C}"          # акцент уведомлений / маркеры
        peach = "${c.base09}"         # interrupted / warning (orange)

        [keys]
        # Префикс как в tmux (core.nix): Ctrl+Space вместо herdr-дефолта Ctrl+B.
        prefix = "ctrl+b"

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
