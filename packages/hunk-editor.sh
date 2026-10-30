# $EDITOR для hunk (собирается в packages/hunk-editor.nix).
# Файл обязан называться `nvim`: hunk передаёт `+LINE FILE` только
# редакторам с basename vim/nvim/vi, остальным — один путь без строки.
#
# Зачем: hunk на каждый `e` синхронно стартует новый $EDITOR и ждёт выхода,
# поэтому LSP поднимается с нуля при каждом открытии. Вместо этого:
#   * внутри nvim ($NVIM задан — hunk запущен из терминала nvim, <leader>gdh)
#     файл открывается в родительском nvim через HunkOpen, а обёртка сразу
#     возвращает управление hunk'у;
#   * из шелла — держим по одному headless nvim-серверу на git-репо и цепляем
#     к нему UI через --remote-ui. `:q` в этом режиме делает :detach, `:qa` гасит сервер (см.
#     nixvim/plugins/git/hunk.nix), так что сервер с прогретым LSP переживает выход.

line=1
file=
for arg in "$@"; do
  case "$arg" in
    +[0-9]*) line=${arg#+} ;;
    *) file=$arg ;;
  esac
done

if [ -z "$file" ]; then
  exec nvim "$@"
fi

# Служебные RPC-вызовы. --headless обязателен: без него клиент при наличии
# tty пытается опросить терминал и ждёт ответа ~1 с на каждый вызов.
rpc() { nvim --headless --server "$1" --remote-expr "$2" >/dev/null 2>&1; }

# Экранирование под vimscript-строку в одинарных кавычках.
expr="v:lua.HunkOpen('${file//\'/\'\'}', $line)"

if [ -n "${NVIM:-}" ]; then
  rpc "$NVIM" "$expr"
  exit $?
fi

root=$(git -C "$(dirname -- "$file")" rev-parse --show-toplevel 2>/dev/null || pwd)
sock="${XDG_RUNTIME_DIR:-/tmp}/nvim-hunk-$(printf '%s' "$root" | sha1sum | cut -c1-12).sock"

alive() { rpc "$sock" 1; }

if ! alive; then
  rm -f -- "$sock"
  (cd -- "$root" && HUNK_NVIM_SERVER=1 setsid nvim --headless --listen "$sock" \
    </dev/null >/dev/null 2>&1 &)
  for _ in $(seq 100); do
    alive && break
    sleep 0.05
  done
  if ! alive; then
    echo "hunk-editor: nvim server did not start, falling back to plain nvim" >&2
    exec nvim "+$line" "$file"
  fi
fi

rpc "$sock" "$expr"
exec nvim --server "$sock" --remote-ui
