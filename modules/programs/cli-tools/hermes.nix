{ ... }:
{
  # Hermes Agent (https://github.com/NousResearch/hermes-agent) — AI-агент от
  # Nous Research. В nixpkgs нет; апстримный flake собирает всё python-окружение
  # через uv2nix (долго и без кэша), поэтому ставим как на обычных дистрибутивах:
  # официальный install.sh разворачивает релиз в ~/.hermes, команда — ~/.local/bin/hermes.
  # Живёт вне /nix/store, обновляется сама (`hermes update`). Скачанные uv'ом
  # бинарники (python/node/ffmpeg) работают через programs.nix-ld (включён в
  # nixos-классе), а CA-сертификаты им отдаёт SSL_CERT_FILE из xdg-defaults.
  flake.modules.homeManager.hermes =
    { pkgs, ... }:
    let
      hermes = pkgs.writeShellApplication {
        name = "hermes";
        runtimeInputs = with pkgs; [
          curl
          git
        ];
        text = ''
          bin="$HOME/.local/bin/hermes"

          # Первый запуск на новой машине: ставим последний stable-релиз.
          if [ ! -e "$bin" ]; then
            curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh \
              | bash -s -- --non-interactive --skip-browser --skip-computer-use
          fi

          exec "$bin" "$@"
        '';
      };
    in
    {
      home.packages = [ hermes ];
    };
}
