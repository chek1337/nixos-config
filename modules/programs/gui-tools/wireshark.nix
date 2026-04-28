{
  flake.modules.nixos.wireshark =
    { pkgs-stable, config, ... }:
    let
      username = config.settings.username;
    in
    {
      programs.wireshark = {
        enable = true;
        package = pkgs-stable.wireshark;
      };
      users.users.${username}.extraGroups = [ "wireshark" ];
    };
}
