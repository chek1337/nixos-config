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
            rev = "7a2d60f4a88a1a7735efde93e03bdb8c7166d00c";
            hash = "sha256-0CKwpNeTt221RXM4SpdUxu/TnghbX2hlIscMGxGaO34=";
          };

          mediainfo = pkgs.fetchFromGitHub {
            owner = "boydaihungst";
            repo = "mediainfo.yazi";
            rev = "49f5ab722d617a64b3bea87944e3e4e17ba3a46b";
            hash = "sha256-PcGrFG06XiJYgBWq+c7fYsx1kjkCvIYRaBiWaJT+xkw=";
          };

          pickle = pkgs.fetchFromGitHub {
            owner = "dimi1357";
            repo = "pickle.yazi";
            rev = "7f5b75c971c7f7db07320c8aa37b59f25936d496";
            hash = "sha256-g1BoqtI97641Fh1pTqlyasKG6+gdAWeeHrC/ouyFw/A=";
          };

          font-sample = subPlugin aminurSrc "font-sample";
          preview-git = subPlugin aminurSrc "preview-git";
          copy-file-contents = subPlugin anirudhSrc "copy-file-contents";

          chmod = pkgs.yaziPlugins.chmod;
          compress = pkgs.yaziPlugins.compress;
          mount = pkgs.yaziPlugins.mount;
          recycle-bin = pkgs.yaziPlugins.recycle-bin;
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
            rev = "b74651dae2fdb02e5706ec8227b2dd33e00f48a9";
            hash = "sha256-XdDUlu43cZUnYDoKhnXlx15jYqnh6ubrbbrzJ0B45vc=";
          };

          pandoc = pkgs.fetchFromGitHub {
            owner = "lmnek";
            repo = "pandoc.yazi";
            rev = "fd2798b79c12d0ee1fc0b8695c2633705529f07b";
            hash = "sha256-3ID/CvogyYA92qpc+lCN1fNovFn4X+pt4iEdKzN2Ncw=";
          };

          convert = pkgs.fetchFromGitHub {
            owner = "atareao";
            repo = "convert.yazi";
            rev = "ce060d9d17e4466d7956213d68a7a74d24ecfdc5";
            hash = "sha256-kCXjwtcOQZbE+S9PgJrBmlzBcdprSGtfiS2Flxe2olw=";
          };

          television = pkgs.fetchFromGitHub {
            owner = "moxuze";
            repo = "television.yazi";
            rev = "8d9ce62c447cc8c9cf7f68f857a6b744820bca4b";
            hash = "sha256-TRz1tpOhVOG55AvkLNxSmwWaElX84+DxvoVdfOwzsTI=";
          };

          whoosh = pkgs.fetchFromGitLab {
            owner = "WhoSowSee";
            repo = "whoosh.yazi";
            rev = "a8807d24e8dd2d2eaab5226b9c35563d417d39f8";
            hash = "sha256-pSMyX8IqjtgglftDxQC9K2m4Z+7pYVm68o3qYpP5fqo=";
          };
        };

        initLua = ''
          require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
          require("eza-preview"):setup({ default_tree = false })
          require("duckdb"):setup({ mode = "standard" })
          require("whoosh"):setup({ jump_notify = true, home_alias_enabled = true })
        '';
      };
    };
}
