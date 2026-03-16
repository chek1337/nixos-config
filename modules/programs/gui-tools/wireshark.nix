{
  flake.modules.nixos.wireshark =
    { pkgs, username, ... }:
    {
      programs.wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
      users.users.${username}.extraGroups = [ "wireshark" ];
    };
}
