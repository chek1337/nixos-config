{ ... }:
{
  flake.overlays.yazi-nightly = final: _prev: {
    yazi-unwrapped = final.stdenv.mkDerivation {
      pname = "yazi-unwrapped";
      version = "26.1.22-unstable-2026-04-26";

      src = final.fetchurl {
        url = "https://github.com/sxyazi/yazi/releases/download/nightly/yazi-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-vWw9WUnhgtDRsU54/zf/XLeQdxqn5bYNTQA0x9Gs2kc=";
      };

      nativeBuildInputs = [
        final.unzip
        final.autoPatchelfHook
      ];

      buildInputs = [ final.stdenv.cc.cc.lib ];

      dontConfigure = true;
      dontBuild = true;
      sourceRoot = ".";

      installPhase = ''
        runHook preInstall

        install -Dm755 "$(find . -type f -name yazi -executable | head -1)" "$out/bin/yazi"
        install -Dm755 "$(find . -type f -name ya   -executable | head -1)" "$out/bin/ya"

        for f in $(find . -path '*/completions/*' -type f); do
          case "$f" in
            *yazi.bash) install -Dm644 "$f" "$out/share/bash-completion/completions/yazi" ;;
            *_yazi)     install -Dm644 "$f" "$out/share/zsh/site-functions/_yazi" ;;
            *yazi.fish) install -Dm644 "$f" "$out/share/fish/vendor_completions.d/yazi.fish" ;;
          esac
        done

        runHook postInstall
      '';

      meta = {
        description = "Blazing fast file manager (nightly prebuilt; bypasses sxyazi/yazi#3671 chafa ghost-key bug)";
        homepage = "https://github.com/sxyazi/yazi";
        license = final.lib.licenses.mit;
        maintainers = [ ];
        mainProgram = "yazi";
        platforms = [ "x86_64-linux" ];
      };
    };
  };
}
