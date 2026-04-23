{ ... }:
{
  flake.modules.homeManager.browser-search =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      toVimiumUrl = url: lib.replaceStrings [ "{}" ] [ "%s" ] url;

      vimiumEntries = lib.concatMapStrings (
        s: s + "\n"
      ) (
        lib.mapAttrsToList (
          shortcut: engine: "${shortcut}: ${toVimiumUrl engine.url} ${engine.description}"
        ) config.browserSearchEngines
      );

      vimiumSearchFile = pkgs.writeText "vimium-search-engines.txt" vimiumEntries;

      vimiumSearchScript = pkgs.writeShellScriptBin "vimium-search" ''
        echo "# Paste these entries into Vimium settings (Custom search engines):"
        echo ""
        cat ${vimiumSearchFile}
      '';
    in
    {
      options.browserSearchEngines = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                description = "Search URL with {} as query placeholder";
              };
              description = lib.mkOption {
                type = lib.types.str;
                description = "Human-readable search engine name";
              };
              default = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Mark this engine as the qutebrowser DEFAULT";
              };
            };
          }
        );
        default = { };
        description = "Unified search engines shared by Vimium and qutebrowser";
      };

      config = {
        home.packages = [ vimiumSearchScript ];

        browserSearchEngines = lib.mkDefault {
          ddg = {
            url = "https://duckduckgo.com/?q={}";
            description = "DuckDuckGo";
            default = true;
          };
          g = {
            url = "https://www.google.com/search?q={}";
            description = "Google";
          };
          yt = {
            url = "https://www.youtube.com/results?search_query={}";
            description = "YouTube";
          };
          gm = {
            url = "https://www.google.com/maps?q={}";
            description = "Google maps";
          };
          ya = {
            url = "https://yandex.ru/search/?text={}";
            description = "Yandex";
          };
          gh = {
            url = "https://github.com/search?q={}";
            description = "GitHub";
          };
          snix = {
            url = "https://search.nixos.org/packages?query={}";
            description = "Nix packages";
          };
        };
      };
    };
}
