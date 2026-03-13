{ inputs, ... }:
{
  flake.modules.homeManager.ks =
    { pkgs, lib, ... }:
    let
      kitty-session = pkgs.buildGoModule {
        pname = "kitty-session";
        version = "unstable-5e975c0";
        src = inputs.kitty-session;
        proxyVendor = true;
        vendorHash = "sha256-aewfTkFkRjxwwDL+ik1XMzkB+H54TABa/rVOXFfbtYk=";
        doCheck = false;

        # Патчим захардкоженные цвета на Nord палитру
        postPatch = ''
          substituteInPlace internal/tui/styles.go \
            --replace '"#7571F9"' '"#81A1C1"' \
            --replace '"#02BF87"' '"#A3BE8C"' \
            --replace '"#FFBF00"' '"#EBCB8B"' \
            --replace '"#636363"' '"#4C566A"' \
            --replace '"#ED567A"' '"#BF616A"' \
            --replace '"#FFFDF5"' '"#ECEFF4"' \
            --replace '"#C1C6B2"' '"#D8DEE9"'
        '';

        meta = {
          description = "Kitty Claude Session Manager";
          homepage = "https://github.com/mad01/kitty-session";
          license = lib.licenses.mit;
          mainProgram = "ks";
        };
      };
    in
    {
      # kitty-session: быстрый cd в репо через fuzzy picker
      programs.zsh.initContent = ''
        repo() { local d=$(ks repo); [[ -n "$d" ]] && cd "$d"; }
      '';

      home.packages = [ kitty-session ];

      # Конфиг kitty-session: директории для fuzzy repo picker
      home.file.".config/ks/config.yaml".text = ''
        dirs:
          - ~/code
          - ~/nixos_config
      '';
    };
}
