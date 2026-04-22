# Optional shell: nushell
# Enabled alongside the main shell so you can enter it on demand via `nu`.
{
  flake.modules.homeManager.nu =
    { ... }:
    {
      programs.nushell = {
        enable = true;
      };

      programs.starship = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
