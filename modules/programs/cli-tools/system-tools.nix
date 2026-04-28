let
  genericPackages =
    { pkgs-stable, ... }:
    {
      environment.systemPackages = with pkgs-stable; [
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
        nix-inspect
        nh
        nvd
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [ genericPackages ];
  };
}
