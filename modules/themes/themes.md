# Themes

Темизацией всей системы управляет одна опция — `config.settings.colorScheme`,
задаётся в host-конфиге (`modules/hosts/<host>/host.nix`). Она же подхватывается:

- **Stylix** — глобальная палитра (`base16Scheme = "${pkgs.base16-schemes}/share/themes/<colorScheme>.yaml"`).
- **Per-scheme overlay** (`modules/themes/_schemes/<colorScheme>.nix`) — обои, иконки, расширение Thunderbird.
- **nvf** (`nvf/plugins/ui/themes/<colorScheme>/default.nix`) — colorscheme-плагин Neovim и его настройка.
- **Noctalia** (`modules/desktop-env/noctalia.nix`) — внутренняя схема панели, через `noctaliaSchemeMap`.
- **lazyvim-nix** (`modules/programs/cli-tools/lazyvim.nix`) — fallback-конфиг для legacy nvim, переключатель `if/else` по имени схемы.

Если для конкретной схемы какой-то слой не определён — он либо берёт fallback (Nord для noctalia/lazyvim), либо просто не подключается (Thunderbird, nvim).

## Поддерживаемые темы

| colorScheme         | Stylix yaml         | Иконки                         | Обои                           | Thunderbird | nvf colorscheme                | Noctalia    | lazyvim    |
|---------------------|---------------------|--------------------------------|--------------------------------|-------------|--------------------------------|-------------|------------|
| `nord`              | `nord.yaml`         | `nordzy-icon-theme`            | `assets/nord2.png`             | nord-dark   | `gbprod/nord.nvim`             | `Nord`      | nord       |
| `catppuccin-mocha`  | `catppuccin-mocha.yaml` | `catppuccin-papirus-folders` | `assets/catppuccin-mocha.png`  | mocha-lavender | `catppuccin/nvim` (mocha)   | `Catppuccin`| catppuccin |
| `gruvbox-dark-hard` | `gruvbox-dark-hard.yaml` | `gruvbox-plus-icons`         | `assets/gruvbox-dark-hard.png` | gruvbox-dark | `ellisonleao/gruvbox.nvim` (hard) | `Gruvbox` | gruvbox    |
| `grayscale-dark`    | `grayscale-dark.yaml` | `papirus-icon-theme`          | `assets/dark-light.jpg`        | —           | `ilyasyoy-monochrome` (dark)   | Nord (fallback) | nord (fallback) |
| `grayscale-light`   | `grayscale-light.yaml` | `papirus-icon-theme`         | `assets/dark-light.jpg`        | —           | `ilyasyoy-monochrome` (light)  | Nord (fallback) | nord (fallback) |

## Детали по темам

### `nord`

- **Иконки:** `Nordzy-dark` / `Nordzy`.
- **Thunderbird:** ставит `nord_dark-1.0-tb.xpi` с addons.thunderbird.net.
- **nvf:** плагин `gbprod/nord.nvim` (собирается из GitHub, см. `nvf/plugins/ui/themes/nord/default.nix`). После загрузки переопределяет:
  - `DiffAdd` → `#022800`, `DiffDelete` → `#3d0100`
  - `NormalFloat` и `FloatBorder` → `#282d37` (через autocmd `ColorScheme *`).

### `catppuccin-mocha`

- **Иконки:** `Papirus-Dark` / `Papirus` из `catppuccin-papirus-folders`.
- **Thunderbird:** `mocha-lavender.xpi` из репо `catppuccin/thunderbird`.
- **nvf:** `pkgs.vimPlugins.catppuccin-nvim` с flavour `mocha`. Включены интеграции для всех плагинов конфига: treesitter, native_lsp (undercurl для всех уровней), blink_cmp, gitsigns, diffview, telescope, harpoon, mini, flash, render_markdown, bufferline, dap, snacks (с `indent_scope_color = "lavender"`), navic и т. д. — полный список в `nvf/plugins/ui/themes/catppuccin-mocha/default.nix`.

### `gruvbox-dark-hard`

- **Иконки:** `Gruvbox-Plus-Dark` / `Gruvbox-Plus-Light`.
- **Thunderbird:** `gruvbox_dark_thunderbird-1.12-tb.xpi`.
- **nvf:** `pkgs.vimPlugins.gruvbox-nvim` с `contrast = "hard"`, без дополнительных хайлайтов.

### `grayscale-dark` / `grayscale-light`

- **Иконки:** `papirus-icon-theme` (`Papirus-Dark` / `Papirus-Light`).
- **Обои:** общие — `assets/dark-light.jpg`.
- **Thunderbird:** не задано (схемы не включают `thunderbird`-атрибут; HM-модуль `modules/themes/themes.nix` использует `lib.optionals (scheme ? thunderbird)`, поэтому это OK).
- **nvf:** обе схемы маппятся на встроенный colorscheme `ilyasyoy-monochrome` (`nvf/plugins/ui/themes/ilyasyoy-monochrome/`). Это in-tree Lua-плагин, собираемый через `vimUtils.buildVimPlugin` из `colors/ilyasyoy-monochrome.lua`. Параметр `background` (`"dark"` или `"light"`) передаётся в setup и переключает палитру внутри Lua-файла.
- **Noctalia / lazyvim:** маппинга нет → fallback на Nord (визуальный mismatch с системой; для grayscale-хоста рекомендуется не использовать noctalia/lazyvim, либо добавить запись).

## Где править при добавлении новой темы

1. `modules/themes/_schemes/<name>.nix` — overlay (обои, иконки, опционально thunderbird).
2. `modules/themes/themes.nix` — добавить запись в `schemes`.
3. `nvf/plugins/ui/themes/<name>/default.nix` — colorscheme-плагин для nvim (или маппинг на существующий, как у grayscale-* → ilyasyoy-monochrome).
4. `nvf/plugins/ui/themes/default.nix` — добавить запись в `themes`.
5. *(опционально)* `modules/desktop-env/noctalia.nix` — `noctaliaSchemeMap`.
6. *(опционально)* `modules/programs/cli-tools/lazyvim.nix` — ветка `if/else` для legacy nvim.

Имя `<name>` должно совпадать с именем yaml-файла в `pkgs.base16-schemes`
(`ls $(nix eval --raw nixpkgs#base16-schemes.outPath)/share/themes/`), иначе stylix
упадёт на этапе evaluation.
