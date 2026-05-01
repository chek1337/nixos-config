# Themes

Темизацией всей системы управляет одна опция — `config.settings.colorScheme`,
задаётся в host-конфиге (`modules/hosts/<host>/host.nix`). Она же подхватывается:

- **Stylix** — глобальная палитра. По умолчанию `base16Scheme = "${pkgs.base16-schemes}/share/themes/<colorScheme>.yaml"`. Если в overlay-файле схемы задан атрибут `base16` (attrset с `base00..base0F`), он отдаётся stylix-у напрямую — yaml-файл из `base16-schemes` не нужен (`base16.nix` принимает path или attrset, см. `mkSchemeAttrs`).
- **Per-scheme overlay** (`modules/themes/_schemes/<colorScheme>.nix`) — обои, иконки, расширение Thunderbird, опциональная inline base16-палитра.
- **nvf** (`nvf/plugins/ui/themes/<colorScheme>/default.nix`) — colorscheme-плагин Neovim и его настройка.
- **Noctalia** (`modules/desktop-env/noctalia.nix`) — внутренняя схема панели, через `noctaliaSchemeMap`.
- **lazyvim-nix** (`modules/programs/cli-tools/lazyvim.nix`) — fallback-конфиг для legacy nvim, переключатель `if/else` по имени схемы.

Если для конкретной схемы какой-то слой не определён — он либо берёт fallback (Nord для noctalia/lazyvim), либо просто не подключается (Thunderbird, nvim).

## Поддерживаемые темы

| colorScheme                  | Stylix base16          | Иконки                         | Обои                           | Thunderbird    | nvf colorscheme                   | Noctalia        | lazyvim         |
|------------------------------|------------------------|--------------------------------|--------------------------------|----------------|-----------------------------------|-----------------|-----------------|
| `nord`                       | yaml `nord.yaml`       | `nordzy-icon-theme`            | `assets/nord2.png`             | nord-dark      | `gbprod/nord.nvim`                | `Nord`          | nord            |
| `catppuccin-mocha`           | yaml `catppuccin-mocha.yaml` | `catppuccin-papirus-folders` | `assets/catppuccin-mocha.png`  | mocha-lavender | `catppuccin/nvim` (mocha)         | `Catppuccin`    | catppuccin      |
| `gruvbox-dark-hard`          | yaml `gruvbox-dark-hard.yaml` | `gruvbox-plus-icons`         | `assets/gruvbox-dark-hard.png` | gruvbox-dark   | `ellisonleao/gruvbox.nvim` (hard) | `Gruvbox`       | gruvbox         |
| `ilyasyoy-monochrome-dark`   | inline (overlay)       | `papirus-icon-theme`           | `assets/dark-light.jpg`        | —              | `ilyasyoy-monochrome` (dark)      | Nord (fallback) | nord (fallback) |
| `ilyasyoy-monochrome-light`  | inline (overlay)       | `papirus-icon-theme`           | `assets/dark-light.jpg`        | —              | `ilyasyoy-monochrome` (light)     | Nord (fallback) | nord (fallback) |

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

### `ilyasyoy-monochrome-dark` / `ilyasyoy-monochrome-light`

- **Stylix:** палитра задаётся inline в `_schemes/ilyasyoy-monochrome-{dark,light}.nix` через атрибут `base16` (attrset `base00..base0F`). `themes.nix` отдаёт её прямо в `stylix.base16Scheme`, поэтому соответствующего yaml в `pkgs.base16-schemes` не нужно. Цвета взяты из палитры lua-colorscheme (`nvf/plugins/ui/themes/ilyasyoy-monochrome/colors/ilyasyoy-monochrome.lua`):
  - монохромные `base00..base07` (bg → fg);
  - акценты `base08..base0F` — semantic-цвета из lua (search, visual, error, cursor, diff add/remove). В light-версии акценты затемнены для читаемости.
- **Иконки:** `papirus-icon-theme` (`Papirus-Dark` / `Papirus-Light`).
- **Обои:** общие — `assets/dark-light.jpg`.
- **Thunderbird:** не задано (`themes.nix` использует `lib.optionals (scheme ? thunderbird)`).
- **nvf:** обе схемы маппятся на in-tree colorscheme `ilyasyoy-monochrome` (`nvf/plugins/ui/themes/ilyasyoy-monochrome/`) — Lua-плагин, собираемый через `vimUtils.buildVimPlugin` из `colors/ilyasyoy-monochrome.lua`. Параметр `background` (`"dark"` или `"light"`) передаётся в setup и переключает палитру внутри Lua-файла.
- **Noctalia / lazyvim:** маппинга нет → fallback на Nord (визуальный mismatch с системой; рекомендуется не использовать на хостах с этими темами либо добавить запись в `noctaliaSchemeMap` / lazyvim).

## Где править при добавлении новой темы

1. `modules/themes/_schemes/<name>.nix` — overlay (обои, иконки, опционально thunderbird, опционально inline `base16` attrset).
2. `modules/themes/themes.nix` — добавить запись в `schemes`.
3. `nvf/plugins/ui/themes/<name>/default.nix` — colorscheme-плагин для nvim (или маппинг на существующий, как у `ilyasyoy-monochrome-{dark,light}` → `./ilyasyoy-monochrome`).
4. `nvf/plugins/ui/themes/default.nix` — добавить запись в `themes`.
5. *(опционально)* `modules/desktop-env/noctalia.nix` — `noctaliaSchemeMap`.
6. *(опционально)* `modules/programs/cli-tools/lazyvim.nix` — ветка `if/else` для legacy nvim.

Если в overlay-файле задан inline `base16`, имя `<name>` может быть произвольным.
Если `base16` нет — имя должно совпадать с yaml-файлом в `pkgs.base16-schemes`
(`ls $(nix eval --raw nixpkgs#base16-schemes.outPath)/share/themes/`), иначе stylix
упадёт на этапе evaluation.
