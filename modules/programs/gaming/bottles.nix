{ ... }:
{
  flake.modules.homeManager.bottles = {
    services.flatpak.packages = [
      "com.usebottles.bottles"
    ];

    programs.zsh.shellAliases = {
      bottles = "flatpak run com.usebottles.bottles";
    };
  };
}
