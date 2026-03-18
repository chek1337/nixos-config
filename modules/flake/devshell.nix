{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };
    in
    {
      formatter = treefmtEval.config.build.wrapper;

      checks.formatting = treefmtEval.config.build.check inputs.self;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nixfmt
          treefmtEval.config.build.wrapper
          sops
        ];
      };
    };
}
