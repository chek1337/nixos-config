{ config, ... }:
let
  inherit (config.flake.lib) nixosMod hmMod;
  modules = [
    "eza"
    "yazi"
    "git"
    "hunk"
    "gh"
    "tmux"
    "television"
    "nix-search-tv"
    # "zellij"
    "nixvim"
    "zoxide"
    "trash-cli"
    "btop"
    "bat"
    "resterm"
    "mermaid"
    # "soundscope"
    # "cmus"
    # "rice"
    # "wallpaper-colorizer"
    "termshark"
    "bandwhich"
    "iftop"
    "bmon"
    "nmap"
    "netcat-gnu"
    "traceroute"
    "mtr"
    "dig"
    "whois"
    "curl"
    "httpie"
    "wget"
    "socat"
    "sshuttle"
    "ripgrep"
    "fd"
    "fzf"
    "just"
    "gnumake"
    "stow"
    "p7zip"
    "atool"
    "unzip"
    "unrar"
    "playerctl"
    "tcpdump"
    "tldr"
    "python3"
    "jq"
    "dua"
    "pciutils"
    "ssh-to-age"
    "nix-inspect"
    "nh"
    "nvd"
    "vim"
    "nixfmt"
  ];
in
{
  flake.modules.nixos.cli-tools = {
    imports = map nixosMod modules;
  };

  flake.modules.homeManager.cli-tools = {
    imports = map hmMod modules;
  };
}
