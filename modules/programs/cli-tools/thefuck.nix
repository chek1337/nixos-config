{
  flake.modules.homeManager.pay-respects =
    { ... }:
    {
      programs.pay-respects = {
        enable = true;
      };
    };
}
