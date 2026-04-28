{
  flake.modules.homeManager.gh =
    { pkgs-stable, lib, ... }:
    {
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
        };
      };

      # home.activation.installGhExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #   export PATH="${
      #     lib.makeBinPath [
      #       pkgs-stable.gh
      #       pkgs-stable.git
      #       pkgs-stable.openssh
      #       pkgs-stable.coreutils
      #     ]
      #   }:$PATH"
      #   export GH_PROTOCOL=https
      #
      #   extensions=(
      #     "dlvhdr/gh-dash"
      #     "gennaro-tedesco/gh-s"
      #     "gennaro-tedesco/gh-f"
      #     "jrnxf/gh-eco"
      #     "meiji163/gh-notify"
      #     "seachicken/gh-poi"
      #     "yusukebe/gh-markdown-preview"
      #     "k1LoW/gh-grep"
      #     "agynio/gh-pr-review"
      #     "mislav/gh-branch"
      #     "mislav/gh-cp"
      #     "yuler/gh-download"
      #     "korosuke613/gh-user-stars"
      #   )
      #
      #   for ext in "''${extensions[@]}"; do
      #     name="''${ext#*/}"
      #     if [ ! -d "$HOME/.local/share/gh/extensions/$name" ]; then
      #       run gh extension install "$ext" || true
      #     fi
      #   done
      # '';
    };
}
