{ ... }:
{
  flake.modules.homeManager.browser-extensions =
    {
      lib,
      pkgs,
      ...
    }:
    {
      options.browserExtensions = {
        chromiumIds = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Chrome Web Store extension IDs for Chromium-based browsers";
        };
        firefoxPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Firefox addon packages for Firefox-based browsers";
        };
      };

      config.browserExtensions = {
        chromiumIds = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
          "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
          "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
          "edibdbjcniadpccecjdfdjjppcpchdlm" # I Still Don't Care About Cookies
        ];
        firefoxPackages = with pkgs.firefoxAddons; [
          ublock-origin
          sponsorblock
          darkreader
          vimium-ff
          privacy-badger17
          decentraleyes
          istilldontcareaboutcookies
        ];
      };
    };
}
