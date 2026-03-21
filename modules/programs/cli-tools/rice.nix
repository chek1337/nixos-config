{ ... }:
{
  flake.modules.homeManager.rice =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cava
        cmatrix
        cbonsai
        pipes-rs
        tty-clock
        lolcat
        figlet
        fastfetch
        onefetch
        nitch
        asciiquarium
        # sl
        cowsay
        fortune
        genact
        lavat
        nyancat
        hollywood
      ];
    };
}
