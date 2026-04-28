{ inputs, ... }:
{
  flake.modules.homeManager.kitty-zoxide-sessions =
    { pkgs-unstable, lib, ... }:
    let
      # kitty-zoxide-sessions: jump to kitty sessions from zoxide history with fzf
      # https://github.com/seankay/kitty-zoxide-sessions
      kitty-zoxide-sessions = pkgs-unstable.stdenv.mkDerivation {
        pname = "kitty-zoxide-sessions";
        version = "0-unstable";

        src = pkgs-unstable.fetchFromGitHub {
          owner = "seankay";
          repo = "kitty-zoxide-sessions";
          rev = "main";
          hash = "sha256-fEBagA3j7xQr8MoTU1jxlfCeJqkjd309Q4OzBpkTAC0=";
        };

        nativeBuildInputs = [ pkgs-unstable.makeWrapper ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/share/kitty-zoxide-sessions

          cp kitty-zoxide-sessions.py $out/bin/kitty-zoxide-sessions
          chmod +x $out/bin/kitty-zoxide-sessions

          # Fix shebang for Nix (no /usr/bin/env python3 in sandbox)
          substituteInPlace $out/bin/kitty-zoxide-sessions \
            --replace "#!/usr/bin/env python3" "#!${pkgs-unstable.python3}/bin/python3"

          # Keep default template in a known store path
          cp default.kitty-session $out/share/kitty-zoxide-sessions/default.kitty-session

          # Ensure fzf and zoxide are always available to the script
          wrapProgram $out/bin/kitty-zoxide-sessions \
            --suffix PATH : ${
              lib.makeBinPath [
                pkgs-unstable.fzf
                pkgs-unstable.zoxide
              ]
            }

          runHook postInstall
        '';
      };
    in
    {
      home.packages = [ kitty-zoxide-sessions ];

      programs.kitty.extraConfig = ''
        # kitty-zoxide-sessions: open zoxide directory picker (ctrl+a then k)
        map ctrl+a>k launch --type=window --bias=25 --location=hsplit ${kitty-zoxide-sessions}/bin/kitty-zoxide-sessions --auto-close --ansi --template ${kitty-zoxide-sessions}/share/kitty-zoxide-sessions/default.kitty-session
      '';
    };
}
