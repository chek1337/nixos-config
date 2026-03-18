{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };

      preCommitCheck = inputs.git-hooks.lib.${system}.run {
        src = inputs.self;
        hooks = {
          treefmt = {
            enable = true;
            package = treefmtEval.config.build.wrapper;
          };
          flake-checker.enable = true;
        };
      };
    in
    {
      formatter = treefmtEval.config.build.wrapper;

      checks = {
        formatting = treefmtEval.config.build.check inputs.self;
        pre-commit = preCommitCheck;
      };

      devShells.default = pkgs.mkShell {
        inherit (preCommitCheck) shellHook;
        packages = with pkgs; [
          nil
          nixfmt
          treefmtEval.config.build.wrapper
          sops
        ];
      };
    };
}
