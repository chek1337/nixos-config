{
  lib,
  config,
  inputs,
  ...
}:
let
  flakeConfig = config;

  mkNixos =
    system: cls: name: username:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit username; };
      modules = [
        flakeConfig.flake.modules.nixos.${cls}
        flakeConfig.flake.modules.nixos."hosts/${name}"
        {
          home-manager.extraSpecialArgs = { inherit username; };
          home-manager.users.${username}.imports = [
            flakeConfig.flake.modules.homeManager.homeManager
            (flakeConfig.flake.modules.homeManager."hosts/${name}" or { })
          ];
          networking.hostName = lib.mkDefault name;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.stateVersion = "25.05";
        }
      ];
    };

  linux = username: name: mkNixos "x86_64-linux" "nixos" name username;
  linux-arm = username: name: mkNixos "aarch64-linux" "nixos" name username;
  wsl = username: name: mkNixos "x86_64-linux" "wsl" name username;

  iso =
    username: name:
    let
      targetSystem = linux username name;
    in
    lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        flakeConfig.flake.modules.nixos.installer
        {
          networking.hostName = "installer-${name}";
          nixpkgs.hostPlatform = "x86_64-linux";
          system.stateVersion = "25.05";

          isoImage.storeContents = [ targetSystem.config.system.build.toplevel ];
          image.fileName = "nixos-${name}-offline.iso";

          isoImage.contents = [
            {
              source = inputs.self;
              target = "/etc/nixos-config";
            }
          ];
        }
      ];
    };
in
{
  flake.lib = {
    mkSystems = {
      inherit
        linux
        linux-arm
        wsl
        iso
        ;
    };

    loadNixosAndHmModuleForUser =
      flakeConfig: modules:
      (builtins.map (module: flakeConfig.flake.modules.nixos.${module} or { }) modules)
      ++ [
        (
          { username, ... }:
          {
            imports = [ inputs.home-manager.nixosModules.home-manager ];
            home-manager.users.${username}.imports = builtins.map (
              module: flakeConfig.flake.modules.homeManager.${module} or { }
            ) modules;
          }
        )
      ];
  };
}
