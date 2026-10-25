{ inputs, ... }:
{
  flake.modules.nixos.nixos =
    { config, lib, ... }:
    let
      username = config.settings.username;
    in
    {
      nix.settings = {
        max-jobs = "auto";
        cores = 0;
        substituters = [
          # Зеркало cache.nixos.org в RU: отдаёт те же NAR'ы с подписью
          # cache.nixos.org-1 (ключ ниже уже её покрывает), но физически лежит
          # в России — под sing-box TUN попадает в geoip-ru и идёт direct, минуя
          # туннель. Замер на 765 МБ NAR: yandex 17.7 MB/s против 0.58 MB/s у
          # cache.nixos.org через туннель. Первый в списке = основной источник,
          # cache.nixos.org остаётся фоллбэком, если зеркало отстало или лежит.
          "https://mirror.yandex.ru/nixos"
          "https://cache.nixos.org"
          # "https://nix-community.cachix.org"
          # "https://zen-browser.cachix.org"
          # "https://yandex-browser-nix.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          # "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
          # "yandex-browser-nix.cachix.org-1:KTUynR1mK6m4ZVPgM2U5cb/yTa9vBGMU+eRY/l/b7vw="
        ];
        # Зеркала cache.nixos.org, которые клиент может включить на один запуск
        # (`just` выбирает их замером перед сборкой). Сами по себе не используются,
        # поэтому мёртвое зеркало не мешает обновлению.
        trusted-substituters = lib.filter (s: s != "") (
          lib.splitString "\n" (builtins.readFile ./mirrors.txt)
        );
        connect-timeout = 3;
        # Склеивать одинаковые файлы в store жёсткими ссылками сразу при
        # добавлении пути. У нас пять разных nixpkgs (unstable, stable и четыре
        # пина), поэтому идентичных файлов в разных путях много: разовый
        # `nix store optimise` на непродедуплицированном store отыграл десятки
        # ГБ. Цена — небольшая задержка при записи новых путей.
        auto-optimise-store = true;
        keep-outputs = true;
        keep-derivations = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      nixpkgs.config.allowUnfree = true;
      # NB: у опции nixpkgs.config поверхностный merge (`//`), поэтому
      # permittedInsecurePackages нельзя объявлять в нескольких модулях —
      # выживет только одно определение. Исключения для stable-пакетов задаются
      # в config'е pkgs-stable (modules/nixos-params/configurations.nix).
      users.users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = [ "wheel" ];
      };
      # Без лимита журнал дорастает до нескольких ГБ (к моменту настройки было
      # 1.6 ГБ). 500 МБ хватает на недели истории.
      services.journald.extraConfig = "SystemMaxUse=500M";
      time.timeZone = config.settings.timeZone;
      i18n.defaultLocale = "ru_RU.UTF-8";
      programs.nix-ld.enable = true;
    };
}
