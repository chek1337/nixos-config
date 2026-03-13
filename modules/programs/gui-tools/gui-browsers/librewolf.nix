{
  flake.modules.homeManager.librewolf =
    { ... }:
    {
      programs.librewolf = {
        enable = true;
        settings = {
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "network.cookie.lifetimePolicy" = 0;
          "browser.startup.page" = 3;
        };
      };
    };
}
