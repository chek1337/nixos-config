{ pkgs, ... }:
{
  extraPackages = [ pkgs.python3Packages.jupytext ];

  plugins.jupytext = {
    enable = true;

    settings = {
      style = "percent";
      output_extension = "py";
      force_ft = "python";
    };
  };
}
