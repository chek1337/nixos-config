{ ... }:
{
  flake.modules.homeManager.rice =
    { pkgs-stable, config, ... }:
    let
      c = config.lib.stylix.colors;
    in
    {
      programs.zsh.shellAliases = {
        lavat = "lavat -g -G -c ${c.base0D-hex} -k ${c.base0E-hex} -R 2";
      };

      home.packages = with pkgs-stable; [
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
