{ inputs, ... }:
{
  flake.modules.homeManager.nixvim =
    { pkgs, config, ... }:
    {
      stylix.targets.neovim.enable = false;

      imports = [ inputs.nixvim.homeModules.nixvim ];

      # Дефолтный «рецепт запуска» AI-серверов (copilot LSP, avante ACP) для
      # NixOS-хостов: гоняем их через vopono в network namespace по WireGuard
      # (как qutebrowser/ayugram — modules/services/unblock/vopono.nix). vopono
      # работает через root-демон vopono.service → sudo/пароль из nvim не нужны.
      # Раньше путь к секрету был зашит module-аргументом; теперь это рантайм-файл,
      # который читает ai_launcher (nixvim/plugins/ai/launcher.nix) и который можно
      # перекрыть на лету через $NVIM_AI_WRAPPER. В standalone .#nvim / на чужой
      # машине этого файла нет → прямой запуск (или свой скрипт).
      #
      # vopono берёт <APPLICATION> ОДНОЙ строкой, поэтому "$*": copilot приходит
      # как `copilot-language-server --stdio`, avante — как `claude-agent-acp`.
      home.file.".config/nvim-ai/wrapper" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec ${pkgs.vopono}/bin/vopono exec --protocol wireguard \
            --custom /run/secrets/${config.settings.wireguardConfigName} "$*"
        '';
      };

      programs.nixvim = {
        enable = true;
        nixpkgs.pkgs = pkgs;
        imports = [
          # Прокидываем обёрнутый standalone-yazi (packages/yazi.nix) как module
          # arg, чтобы плагин qol/yazi брал его и в HM-сборке, а не только в
          # standalone-пакете (packages/nvim.nix, где он идёт через
          # extraSpecialArgs).
          { _module.args.yaziPkg = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.yazi; }
          ./options.nix
          ./keymaps.nix
          ./keymaps-ru.nix
          ./spellfiles.nix
          ./plugins
        ];
        colorScheme = config.settings.colorScheme;
      };
      programs.zsh.shellAliases = {
        v = "nvim";
        ngit = "nvim +Neogit";
      };
    };
}
