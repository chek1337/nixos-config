{
  flake.modules.homeManager.yazi-plugins =
    { pkgs, ... }:
    let
      aminurSrc = pkgs.fetchFromGitHub {
        owner = "AminurAlam";
        repo = "yazi-plugins";
        rev = "8ed61d7c0cc1902963f59020d3c87f505adc8273";
        hash = "sha256-KEz/o1Sk5hydzMSje/2u80hnuBnUyDxnMhyT00T4zQI=";
      };
      anirudhSrc = pkgs.fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "plugins-yazi";
        rev = "71545f4ee1a0896c555b3118dc3d2b0a1b92fad9";
        hash = "sha256-JsQJg/SfXLQ/JIpl2YsfzdGpS1ZeWIACJwWTpHaVH3w=";
      };
      subPlugin =
        src: name:
        pkgs.runCommand "${name}.yazi" { } ''
          cp -r ${src}/${name}.yazi $out
        '';
      # С yazi 26.8.15 tab.selected отдаёт File, а не Url (sxyazi/yazi#4096),
      # и tostring(File) даёт "File: 0x...", а не путь. Переименовываем
      # переменную цикла и возвращаем Url под старым именем. --replace-fail
      # упадёт, когда upstream починит плагин, — тогда патч можно снимать.
      fixSelected =
        src:
        pkgs.runCommand "${src.name}-selected-fix" { } ''
          cp -r ${src} $out
          chmod -R u+w $out
          substituteInPlace $out/main.lua --replace-fail \
            'for _, u in pairs(tab.selected) do' \
            'for _, f in pairs(tab.selected) do local u = f.url'
        '';
    in
    {
      programs.yazi = {
        plugins = {
          piper = pkgs.yaziPlugins.piper;
          relative-motions = pkgs.yaziPlugins.relative-motions;
          duckdb = pkgs.yaziPlugins.duckdb;
          ouch = pkgs.yaziPlugins.ouch;
          toggle-pane = pkgs.yaziPlugins.toggle-pane;

          eza-preview = pkgs.fetchFromGitHub {
            owner = "ahkohd";
            repo = "eza-preview.yazi";
            rev = "e8fb6c8c57bc5f94ff269089078e76c8ed77cd21";
            hash = "sha256-8isGaJSVu7R76hKfGRszMdBOItYjVOKqvDpv9ccpBAs=";
          };

          mediainfo = pkgs.fetchFromGitHub {
            owner = "boydaihungst";
            repo = "mediainfo.yazi";
            rev = "f1cec0b43a6b5904e1638ad050f044c4eb1383da";
            hash = "sha256-p+wfTgQ4Td7Q/AIzsECzijam3NcPXxEPrpnUnT/028E=";
          };

          pickle = pkgs.fetchFromGitHub {
            owner = "dimi1357";
            repo = "pickle.yazi";
            rev = "7f5b75c971c7f7db07320c8aa37b59f25936d496";
            hash = "sha256-g1BoqtI97641Fh1pTqlyasKG6+gdAWeeHrC/ouyFw/A=";
          };

          font-sample = subPlugin aminurSrc "font-sample";
          preview-git = subPlugin aminurSrc "preview-git";
          copy-file-contents = fixSelected (subPlugin anirudhSrc "copy-file-contents");

          chmod = pkgs.yaziPlugins.chmod;
          # 0.6 из nixpkgs зовёт fs.unique_name() и читает Url из
          # tab.selected — на yazi 26.8+ падает. В upstream main исправлено.
          compress = pkgs.fetchFromGitHub {
            owner = "KKV9";
            repo = "compress.yazi";
            rev = "80e5268ec74c7ac17d4d739e13a9958cba4c70d3";
            hash = "sha256-9cdA8D/TtwHcLqrtoyIixA0YJmTs+c8FSNrjxp8CYI0=";
          };
          mount = pkgs.yaziPlugins.mount;
          recycle-bin = fixSelected pkgs.yaziPlugins.recycle-bin;
          restore = pkgs.yaziPlugins.restore;

          fast-enter = pkgs.fetchFromGitHub {
            owner = "ourongxing";
            repo = "fast-enter.yazi";
            rev = "9fe77d8292c6bc63538acdc97cb91b81542e85a4";
            hash = "sha256-E0r0XsyECKMJ8w+9OVJKDggSXhAqlwD3u9ZSEXHc6J0=";
          };

          ucp = pkgs.fetchFromGitHub {
            owner = "simla33";
            repo = "ucp.yazi";
            rev = "5ef8203d9d061f57b444b2c031f3b6172b060a03";
            hash = "sha256-G6PiS+srbxNu30Vz9Q1k3thfuQySMuNpdtmwgf6CjQc=";
          };

          pandoc = pkgs.fetchFromGitHub {
            owner = "lmnek";
            repo = "pandoc.yazi";
            rev = "6a1e07d9a9f3ba28198c8c59c1c450d9dacaba0f";
            hash = "sha256-S/8tfxIbsmEp6+fPLNwl5Jbk+SF/9Rg5yeQPcr+k5vM=";
          };

          convert = fixSelected (
            pkgs.fetchFromGitHub {
              owner = "atareao";
              repo = "convert.yazi";
              rev = "ce060d9d17e4466d7956213d68a7a74d24ecfdc5";
              hash = "sha256-kCXjwtcOQZbE+S9PgJrBmlzBcdprSGtfiS2Flxe2olw=";
            }
          );

          television = pkgs.fetchFromGitHub {
            owner = "moxuze";
            repo = "television.yazi";
            rev = "8d9ce62c447cc8c9cf7f68f857a6b744820bca4b";
            hash = "sha256-TRz1tpOhVOG55AvkLNxSmwWaElX84+DxvoVdfOwzsTI=";
          };

          whoosh = pkgs.fetchFromGitLab {
            owner = "WhoSowSee";
            repo = "whoosh.yazi";
            rev = "47100012460ae5292cb837fca5444fecfd78f4a5";
            hash = "sha256-BerfIDF8EHTnAELVSoaFAEoX+8gNIbkAFfeA38vStf0=";
          };
        };

        initLua = ''
          require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
          require("eza-preview"):setup({ default_tree = false })
          require("duckdb"):setup({ mode = "standard" })
          require("whoosh"):setup({ jump_notify = true, home_alias_enabled = true })
          require("recycle-bin"):setup()
        '';
      };
    };
}
