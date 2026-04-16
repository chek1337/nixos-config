{ lib, ... }:
{
  imports =
    let
      files = builtins.readDir ./.;
    in
    lib.pipe files [
      (lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ))
      (lib.mapAttrsToList (name: _: ./. + "/${name}"))
    ];
}
