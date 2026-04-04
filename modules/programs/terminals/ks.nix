{ inputs, ... }:
{
  flake.modules.homeManager.ks =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      c = config.lib.stylix.colors;
      kitty-session = pkgs.buildGoModule {
        pname = "kitty-session";
        version = "unstable-5e975c0";
        src = inputs.kitty-session;
        proxyVendor = true;
        vendorHash = "sha256-aewfTkFkRjxwwDL+ik1XMzkB+H54TABa/rVOXFfbtYk=";
        doCheck = false;

        # Патчим захардкоженные цвета на текущую Stylix-палитру
        postPatch = ''
          substituteInPlace internal/tui/styles.go \
            --replace '"#7571F9"' '"#${c.base0D-hex}"' \
            --replace '"#02BF87"' '"#${c.base0B-hex}"' \
            --replace '"#FFBF00"' '"#${c.base0A-hex}"' \
            --replace '"#636363"' '"#${c.base03-hex}"' \
            --replace '"#ED567A"' '"#${c.base08-hex}"' \
            --replace '"#FFFDF5"' '"#${c.base06-hex}"' \
            --replace '"#C1C6B2"' '"#${c.base04-hex}"'
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
