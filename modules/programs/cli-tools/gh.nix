{ inputs, ... }:
{
  flake.modules.homeManager.gh =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      home.packages = [
        inputs.ghgrab.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      xdg.configFile."ghgrab/theme.toml".text =
        let
          c = config.lib.stylix.colors.withHashtag;
        in
        ''
          bg_color       = "${c.base00}"
          fg_color       = "${c.base05}"
          accent_color   = "${c.base0D}"
          warning_color  = "${c.base0A}"
          error_color    = "${c.base08}"
          success_color  = "${c.base0B}"
          folder_color   = "${c.base0C}"
          selected_color = "${c.base09}"
          border_color   = "${c.base03}"
          highlight_bg   = "${c.base01}"
        '';

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
      #       pkgs.gh
      #       pkgs.git
      #       pkgs.openssh
      #       pkgs.coreutils
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
