{ ... }:
{
  vim.utility.snacks-nvim.setupOpts = {
    bigfile.enable = true;
    animate.enable = true;
    indent.enable = true;
    scroll = {
      enable = true;
      animate = {
        duration = {
          step = 10;
          total = 200;
        };
        easing = "outExpo";
      };
    };
    notifier = {
      enable = true;
      timeout = 2000;
      style = "minimal";
    };
    statuscolumn.enable = true;
    scope.enable = true;
    quickfile.enable = true;
    words.enable = true;
  };
}
