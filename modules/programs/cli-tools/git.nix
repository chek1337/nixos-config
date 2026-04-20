{
  flake.modules.homeManager.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user.name = "chek1337";
          user.email = "DaniPlay1337@yandex.ru";
          pull.rebase = true;
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
