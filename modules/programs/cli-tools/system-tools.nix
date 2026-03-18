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
        playerctl
        tcpdump
        dig
        tldr
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [ genericPackages ];
  };
}
