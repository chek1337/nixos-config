# To add a Thunderbird theme for a new color scheme:
#
# 1. Find the .xpi file for the theme:
#    - Search https://addons.thunderbird.net for the theme by name
#    - Use the ATN API to get the download URL:
#        curl "https://services.addons.thunderbird.net/api/v4/addons/addon/<slug>/" | jq '{url: .current_version.files[0].url, id: .guid}'
#      where <slug> is the addon slug from the URL, e.g. "nord-dark" or "gruvbox-dark-thunderbird"
#    - Alternatively, find the .xpi directly in the theme's GitHub repository
#
# 2. Get the file hash:
#    nix-prefetch-url --type sha256 <url>
#    nix hash convert --hash-algo sha256 --to sri <hash>
#
# 3. Get the gecko extension ID (optional, for verification):
#    nix-shell -p unzip jq --run "unzip -qc <file.xpi> manifest.json | jq -r '(.applications.gecko.id // .browser_specific_settings.gecko.id)'"
#
# 4. Add the thunderbird derivation to modules/themes/_schemes/<scheme>.nix
#    following the pattern of existing schemes (nord, gruvbox-dark-hard, catppuccin-mocha)
#
# 5. After applying the config and restarting Thunderbird, a puzzle-piece icon will appear
#    in the top-right corner notifying about the newly installed extension — click it to apply
#    the theme immediately, or it will be applied automatically after a full system restart
{
  flake.modules.homeManager.thunderbird =
    { ... }:
    {
      programs.thunderbird = {
        enable = true;
        profiles."default" = {
          isDefault = true;
        };
      };

      # accounts.email.accounts."YA-daniplay".thunderbird = {
      #   enable = true;
      #   profiles = [ "default" ];
      # };
      # accounts.email.accounts."YA-loychenko".thunderbird = {
      #   enable = true;
      #   profiles = [ "default" ];
      # };

    };
}
