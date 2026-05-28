{ ... }:
{
  plugins.dap-python = {
    enable = true;
    lazyLoad.settings.ft = "python";
    adapterPythonPath = "debugpy-adapter";
  };
}
