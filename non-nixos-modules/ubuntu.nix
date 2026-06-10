# Не настоящий NixOS-хост, а standalone home-manager конфигурация для
# Ubuntu и прочих не-NixOS машин с установленным nix.
#
# ВАЖНО: hostname здесь — просто уникальное имя конфигурации, оно не обязано
# совпадать с hostname машины. Имена существующих NixOS-хостов занимать
# нельзя (получится дубль модуля hosts/<name> и ошибки вида
# "option ... is already declared").
#
# Установка:
#   nix run home-manager -- switch --flake github:chek1337/nixos-config#chek@ubuntu-work
# или из клона репо:
#   nix run home-manager -- switch --flake .#chek@ubuntu-work
{ config, ... }:
let
  flakeConfig = config;
  hostname = "ubuntu-work";
  username = "chek";
  modules = [
    # "themes"
    "zsh"
    "kitty"
    "tmux"
    "nixvim"
    "vopono-portable"
  ];
  sharedSettings = {
    colorScheme = "nord";
  };
in
{
  flake = {
    homeConfigurations."${username}@${hostname}" =
      flakeConfig.flake.lib.mkHomes.home-linux username hostname;

    modules.homeManager."hosts/${hostname}" = {
      imports = flakeConfig.flake.lib.loadHmModules modules;

      settings = sharedSettings;

      # Не-NixOS: интеграция с системным окружением (XDG, sessionVars)
      # и fontconfig для шрифтов из HM-профиля (нужно kitty).
      targets.genericLinux.enable = true;
      fonts.fontconfig.enable = true;
    };
  };
}
