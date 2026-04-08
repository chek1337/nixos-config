{ inputs, ... }:
{
  flake.modules.homeManager.yandex-browser =
    { ... }:
    {
      home.packages = [
        (inputs.yandex-browser.packages.x86_64-linux.yandex-browser-stable.override {
          extensions = [
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
            "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
            "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
            "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
            "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
            "ldpochfccmkkmhdbclfhpagapcfdljkj" # Decentraleyes
            "edibdbjcniadpccecjdfdjjppcpchdlm" # I Still Don't Care About Cookies
          ];
        })
      ];
    };
}
