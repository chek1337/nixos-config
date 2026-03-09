let
  genericPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        vim
        btop
        ripgrep
        fd
        just
        fzf
        nixfmt
        fastfetch
        stow
        p7zip
        playerctl
        tcpdump
        dig
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [ genericPackages ];
  };
}
