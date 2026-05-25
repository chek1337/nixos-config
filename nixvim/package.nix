{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      nixvimPkg = inputs.nixvim.legacyPackages.${system}.makeNixvim {
        imports = [
          ./options.nix
        ];
      };
    in
    {
      packages.nixvim = nixvimPkg;
      apps.nixvim = {
        type = "app";
        program = "${nixvimPkg}/bin/nvim";
      };
    };
}
