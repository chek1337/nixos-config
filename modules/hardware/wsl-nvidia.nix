{ ... }:
{
  flake.modules.nixos.wsl-nvidia =
    { ... }:
    {
      wsl.useWindowsDriver = true; # пробрасывает /usr/lib/wsl/lib

      environment.sessionVariables = {
        LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
      };
    };
}
