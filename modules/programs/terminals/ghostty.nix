{ ... }:
{
  flake.modules.homeManager.ghostty =
    { pkgs-stable, ... }:
    let
      cursorShaders = pkgs-stable.fetchFromGitHub {
        owner = "sahaj-b";
        repo = "ghostty-cursor-shaders";
        rev = "4faa83e4b9306750fc8de64b38c6f53c57862db8";
        hash = "sha256-ruhEqXnWRCYdX5mRczpY3rj1DTdxyY3BoN9pdlDOKrE=";
      };
    in
    {
      programs.ghostty = {
        enable = true;
        settings = {
          confirm-close-surface = false;
          custom-shader = "${cursorShaders}/cursor_warp.glsl";
          custom-shader-animation = "always";
        };
      };
    };
}
