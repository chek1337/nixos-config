{
  flake.modules.homeManager.mermaid =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.mermaid-cli
        pkgs.xdg-utils
      ];

      programs.zsh.shellAliases = {
        mmd = "mmdc";
      };

      programs.zsh.initContent = ''
        _mmd_render() {
          emulate -L zsh

          local format="$1"
          shift

          if (( $# < 1 )); then
            print -u2 "usage: mmd''${format} <input.mmd> [output.''${format}] [mmdc args...]"
            return 2
          fi

          local input="$1"
          shift
          local output

          if (( $# > 0 )) && [[ "$1" == *.''${format} ]]; then
            output="$1"
            shift
          else
            output="''${input:r}.''${format}"
          fi

          command mmdc -i "$input" -o "$output" "$@" >&2 || return
          print -r -- "$output"
        }

        _mmd_has_scale_arg() {
          emulate -L zsh

          local arg
          for arg in "$@"; do
            [[ "$arg" == "-s" || "$arg" == "--scale" || "$arg" == --scale=* ]] && return 0
          done

          return 1
        }

        mmdsvg() { _mmd_render svg "$@" }
        mmdpng() {
          if _mmd_has_scale_arg "$@"; then
            _mmd_render png "$@"
          else
            _mmd_render png "$@" --scale 3
          fi
        }
        mmdpdf() { _mmd_render pdf "$@" }

        mmdopen() {
          emulate -L zsh

          local output
          output="$(_mmd_render svg "$@")" || return
          command xdg-open "$output" > /dev/null 2>&1 & disown
        }

        mmdo() { mmdopen "$@" }
      '';
    };
}
