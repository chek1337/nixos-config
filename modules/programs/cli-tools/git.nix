{
  flake.modules.homeManager.git =
    { config, lib, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user.name = "chek1337";
          user.email = "DaniPlay1337@yandex.ru";
          user.useConfigOnly = true;
          pull.rebase = true;
        };

        # Включается только когда хост задаёт settings.work (см. host.nix).
        # TODO на хосте, где появится работа:
        #   1. Сгенерировать отдельный SSH-ключ: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work
        #   2. Зарегистрировать ~/.ssh/id_ed25519_work.pub в GitLab.
        #   3. Клонировать рабочие репо в settings.work.workDir (по умолчанию ~/Work/).
        includes = lib.optional (config.settings.work != null) {
          condition = "gitdir:${config.settings.work.workDir}";
          contents = {
            user.name = config.settings.work.name;
            user.email = config.settings.work.email;
          }
          // lib.optionalAttrs (config.settings.work.sshKeyPath != null) {
            core.sshCommand = "ssh -i ${config.settings.work.sshKeyPath} -o IdentitiesOnly=yes";
          };
        };
      };

      home.shellAliases = {
        gdsbs = "git -c delta.side-by-side=true diff";
        gdsbss = "git -c delta.side-by-side=true diff --staged";
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          side-by-side = false;
          line-numbers = true;
          navigate = true;
        };
      };
    };
}
