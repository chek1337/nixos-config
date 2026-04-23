let
  genericPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        vim
        ripgrep
        fd
        just
        fzf
        nixfmt

        stow
        p7zip
        atool
        unzip
        unrar
        playerctl
        tcpdump
        dig
        tldr
        python3
        jq
        dua
        pciutils
        toybox
        ssh-to-age
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [ genericPackages ];
  };
}
