{ pkgs }:
let
  ilyasyoy-monochrome = pkgs.vimUtils.buildVimPlugin {
    pname = "ilyasyoy-monochrome";
    version = "0.1.0";
    src = pkgs.runCommand "ilyasyoy-monochrome-src" { } ''
      mkdir -p $out/colors
      cp ${./colors/ilyasyoy-monochrome.lua} $out/colors/ilyasyoy-monochrome.lua
    '';
  };
in
{
  package = ilyasyoy-monochrome;

  setup = # lua
    ''
      vim.o.background = "dark"
      vim.cmd.colorscheme("ilyasyoy-monochrome")
    '';
}
