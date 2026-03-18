{
  flake.modules.nixos.wireshark =
    { pkgs, config, ... }:
    let
      username = config.settings.username;
    in
    {
      programs.wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
      users.users.${username}.extraGroups = [ "wireshark" ];
    };
}
