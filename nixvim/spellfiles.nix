{ pkgs, lib, ... }:
let
  mirror = "https://ftp.nluug.nl/vim/runtime/spell";
  files = {
    "ru.utf-8.spl" = "sha256-6y0714ogILMLzAp8/r2s6/t6QnWBEU9muIpXeubaxU0=";
    "ru.utf-8.sug" = "sha256-6r2GForYXVv7gGiAjPeYK6sDdK/CmctJ7MidcWFvOTs=";
  };
in
{
  extraFiles = lib.mapAttrs' (name: hash: {
    name = "spell/${name}";
    value.source = pkgs.fetchurl {
      url = "${mirror}/${name}";
      inherit hash;
    };
  }) files;
}
