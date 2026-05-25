{ ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      bigfile.enabled = true;
      animate.enabled = true;
      indent.enabled = true;
      scroll = {
        enabled = true;
        animate = {
          duration = {
            step = 10;
            total = 200;
          };
          easing = "outExpo";
        };
      };
      notifier = {
        enabled = true;
        timeout = 2000;
        style = "minimal";
      };
      statuscolumn.enabled = true;
      scope.enabled = true;
      quickfile.enabled = true;
      words.enabled = true;
    };
  };
}
