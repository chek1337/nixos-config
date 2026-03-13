{
  flake.modules.homeManager.yazi =
    { ... }:
    {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";

        settings = {
          mgr = {
            ratio = [
              1
              2
              4
            ];
          };
        };
      };
    };
}
