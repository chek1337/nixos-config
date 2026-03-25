{ inputs, ... }:
{
  flake.modules.homeManager.yandex-browser =
    { ... }:
    {
      home.packages = [
        inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable
      ];
    };
}
