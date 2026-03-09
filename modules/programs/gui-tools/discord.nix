{ ... }:
{
  flake.modules.homeManager.discord =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
        (discord.override {
          withEquicord = true;
        })
      ];
    };
}
