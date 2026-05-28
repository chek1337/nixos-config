{ pkgs, ... }:
{
  extraPackages = [ pkgs.python3Packages.jupytext ];

  # Eager: setup() — это `nvim_create_autocmd("BufReadCmd", { pattern = "*.ipynb" })`.
  # Любая лень = autocmd регистрируется после первого открытия .ipynb, и тот
  # файл прочитается как сырой JSON. `ft = "python"` бесполезен (filetype
  # выставляется после BufReadCmd). Setup стоит доли мс — не трогаем.
  plugins.jupytext = {
    enable = true;

    settings = {
      style = "percent";
      output_extension = "py";
      force_ft = "python";
    };
  };
}
