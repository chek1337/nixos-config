{
  flake.modules.homeManager.yazi-previewers =
    { ... }:
    {
      programs.yazi.settings.plugin = {
        prepend_previewers = [
          # Plugin-based previewers
          {
            url = "**/.git/";
            run = "preview-git";
          }
          {
            url = "*/";
            run = "eza-preview";
          }
          {
            url = "*.csv";
            run = "duckdb";
          }
          {
            url = "*.tsv";
            run = "duckdb";
          }
          {
            url = "*.json";
            run = "duckdb";
          }
          {
            url = "*.parquet";
            run = "duckdb";
          }
          {
            url = "*.xlsx";
            run = "duckdb";
          }
          {
            url = "*.duckdb";
            run = "duckdb";
          }
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch";
          }
          {
            mime = "video/*";
            run = "mediainfo";
          }
          {
            mime = "audio/*";
            run = "mediainfo";
          }
          {
            mime = "image/*";
            run = "mediainfo";
          }
          {
            mime = "font/*";
            run = "font-sample";
          }
          {
            mime = "application/ms-opentype";
            run = "font-sample";
          }
          {
            url = "*.{otf,ttf,woff,woff2}";
            run = "font-sample";
          }
          {
            url = "*.pkl";
            run = "pickle";
          }
          {
            url = "*.pickle";
            run = "pickle";
          }
          # Piper-based previewers
          {
            url = "*.md";
            run = ''piper -- env CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          }
          {
            mime = "application/sqlite3";
            run = ''piper -- sqlite3 "$1" ".schema --indent"'';
          }
          {
            mime = "application/bittorrent";
            run = ''piper -- transmission-show "$1"'';
          }
        ];
        prepend_preloaders = [
          {
            mime = "video/*";
            run = "mediainfo";
          }
          {
            mime = "audio/*";
            run = "mediainfo";
          }
          {
            mime = "image/*";
            run = "mediainfo";
          }
          {
            mime = "font/*";
            run = "font-sample";
          }
          {
            mime = "application/ms-opentype";
            run = "font-sample";
          }
          {
            url = "*.{otf,ttf,woff,woff2}";
            run = "font-sample";
          }
        ];
        append_previewers = [
          {
            url = "*";
            run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
          }
        ];
      };
    };
}
