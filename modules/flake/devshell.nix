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
        shellHook = ''
          ${preCommitCheck.shellHook}

          # Install post-commit hook: update .git-commit-msg with commit subject for boot entry labels
          if [ -d .git ]; then
            cat > .git/hooks/post-commit << 'HOOK'
          #!/bin/bash
          # Skip if triggered by our own amend
          [ -n "$_UPDATING_BOOT_LABEL" ] && exit 0
          git log -1 --format=%s > .git-commit-msg
          if ! git diff --quiet -- .git-commit-msg 2>/dev/null; then
            git add .git-commit-msg
            _UPDATING_BOOT_LABEL=1 git commit --amend --no-edit --no-verify
          fi
          HOOK
            chmod +x .git/hooks/post-commit
          fi
        '';
        packages = with pkgs; [
          nil
          nixfmt
          treefmtEval.config.build.wrapper
          sops
        ];
      };
    };
}
