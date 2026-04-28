{ ... }:
{
  flake.modules.homeManager.lutris =
    { pkgs, ... }:
    {
      programs.lutris = {
        enable = true;
        # Workaround i686 openldap test failure (test017-syncreplication-refresh):
        # перехватываем buildFHSEnv в multiPkgs и подменяем openldap на
        # вариант с doCheck = false. Хэш самого pkgs.openldap не меняется,
        # поэтому остальная система берётся из кэша.
        # Убрать, когда upstream nixpkgs починят openldap для i686.
        package = pkgs.lutris.override {
          buildFHSEnv =
            args:
            pkgs.buildFHSEnv (
              args
              // {
                multiPkgs =
                  envPkgs:
                  let
                    originalPkgs = args.multiPkgs envPkgs;
                    customLdap = envPkgs.openldap.overrideAttrs (_: {
                      doCheck = false;
                    });
                  in
                  builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
              }
            );
        };
        extraPackages = with pkgs; [
          mangohud
          winetricks
          gamescope
          gamemode
        ];
      };
    };
}
