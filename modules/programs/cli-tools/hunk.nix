{ inputs, ... }:
let
  nc = inputs.nix-colorizer;
  # Linear (gamma-space) per-channel mix, matching hunk's upstream blendHex.
  # nix-colorizer's own `blend` interpolates in OKLCH and rotates hue through
  # unwanted colors (slate + sage midpoint comes out mauve), so it is unusable
  # for subtle diff tints — do the plain sRGB lerp ourselves.
  mix =
    a: b: t:
    let
      ra = nc.hex.to.srgb a;
      rb = nc.hex.to.srgb b;
      l = x: y: x + (y - x) * t;
    in
    nc.srgb.to.hex {
      r = l ra.r rb.r;
      g = l ra.g rb.g;
      b = l ra.b rb.b;
      a = 1.0;
    };
in
{
  flake.modules.homeManager.hunk =
    { config, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;

      # Map the active Stylix colorScheme to a bundled hunk/Shiki syntax theme.
      # Syntax token colors come from this theme (rich, full-scope highlighting);
      # everything else (surfaces, diff tints, chrome) is overridden from the
      # live Stylix palette below so hunk matches the rest of the system.
      #
      # IMPORTANT: do NOT add a `syntax` block back. Providing one forces
      # syntaxTheme = undefined upstream, which drops Shiki highlighting and
      # falls back to a flat 11-color semantic remap (themes.ts buildCustomTheme).
      schemeThemes = {
        nord = {
          base = "nord";
          dark = true;
        };
        catppuccin-mocha = {
          base = "catppuccin-mocha";
          dark = true;
        };
        gruvbox-dark-hard = {
          base = "gruvbox-dark-hard";
          dark = true;
        };
        ilyasyoy-monochrome-dark = {
          base = "github-dark-dimmed";
          dark = true;
        };
        ilyasyoy-monochrome-light = {
          base = "github-light-default";
          dark = false;
        };
      };
      active =
        schemeThemes.${config.settings.colorScheme} or {
          base = "github-dark-default";
          dark = true;
        };

      # Subtle, polarity-aware diff tints: blend the semantic sign color into the
      # editor background instead of darkening it to near-black.
      rowTint = if active.dark then 0.14 else 0.10; # whole added/removed row
      contentTint = if active.dark then 0.26 else 0.20; # word-level emphasis
      selTint = if active.dark then 0.22 else 0.16; # selected hunk / accent fill
    in
    {
      imports = [ inputs.hunk.homeManagerModules.default ];

      programs.hunk = {
        enable = true;
        enableGitIntegration = false; # git diff goes through delta (see git.nix)

        settings = {
          theme = "custom";
          line_numbers = true;

          custom_theme = {
            base = active.base;
            label = "Stylix ${config.settings.colorScheme}";

            # ---- Surfaces & chrome (from the Stylix palette) ----
            background = c.base00;
            panel = c.base00;
            panelAlt = c.base01;
            border = c.base03;
            accent = c.base0D;
            accentMuted = mix c.base00 c.base0D selTint;
            text = c.base05;
            muted = c.base04;

            contextBg = c.base00;
            contextContentBg = c.base00;
            lineNumberBg = c.base00;
            lineNumberFg = c.base04;
            selectedHunk = mix c.base00 c.base0D selTint;

            # ---- Diff rows ----
            addedSignColor = c.base0B;
            removedSignColor = c.base08;
            addedBg = mix c.base00 c.base0B rowTint;
            removedBg = mix c.base00 c.base08 rowTint;
            movedAddedBg = mix c.base00 c.base0C rowTint;
            movedRemovedBg = mix c.base00 c.base09 rowTint;
            addedContentBg = mix c.base00 c.base0B contentTint;
            removedContentBg = mix c.base00 c.base08 contentTint;

            # ---- Badges & file-status markers ----
            badgeAdded = c.base0B;
            badgeRemoved = c.base08;
            badgeNeutral = c.base0A;
            fileNew = c.base0B;
            fileDeleted = c.base08;
            fileRenamed = c.base0C;
            fileModified = c.base0D;
            fileUntracked = c.base0A;

            # ---- Agent notes ----
            noteBorder = c.base0D;
            noteBackground = c.base01;
            noteTitleBackground = c.base02;
            noteTitleText = c.base05;
          };
        };
      };
    };
}
