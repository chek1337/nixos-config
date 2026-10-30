{ lib, ... }:
let
  # Выключенные модули: файл остаётся, но не импортируется.
  disabled = [ "copilot.nix" ];
in
{
  imports =
    let
      files = builtins.readDir ./.;
    in
    lib.pipe files [
      (lib.filterAttrs (
        name: type:
        type == "regular"
        && lib.hasSuffix ".nix" name
        && name != "default.nix"
        && !(lib.elem name disabled)
      ))
      (lib.mapAttrsToList (name: _: ./. + "/${name}"))
    ];
}
