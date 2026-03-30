{ ... }:
{
  flake.modules.nixos.bottles = {
    services.flatpak.packages = [
      "com.usebottles.bottles"
    ];
  };

  flake.modules.homeManager.bottles =
    { config, ... }:
    let
      wgName = config.settings.wireguardConfigName;
    in
    {
      programs.zsh.shellAliases = {
        bottles = "flatpak run com.usebottles.bottles";
        bottles-vpn = "vopono exec --custom /run/secrets/${wgName} --protocol wireguard \"SUDO_COMMAND='' flatpak run --share=network com.usebottles.bottles\"";
      };
    };
}
