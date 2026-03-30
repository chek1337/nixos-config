{ ... }:
{
  flake.modules.nixos.bottles = {
    services.flatpak.packages = [
      "com.usebottles.bottles"
      "runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08"
      "runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/25.08"
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
