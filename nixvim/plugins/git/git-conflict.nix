{ ... }:
{
  plugins.git-conflict = {
    enable = true;
    lazyLoad.settings.event = [
      "BufReadPost"
      "BufNewFile"
    ];
  };
}
