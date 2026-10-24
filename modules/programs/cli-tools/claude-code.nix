{ inputs, ... }:
{
  flake.modules.homeManager.claude-code =
    { pkgs, ... }:
    {
      home.packages = [ inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];

      # Запуск через локальный HTTP-прокси v2rayN.
      programs.zsh.shellAliases.claude-proxy = "env -u all_proxy -u ALL_PROXY http_proxy=http://127.0.0.1:10808 https_proxy=http://127.0.0.1:10808 HTTP_PROXY=http://127.0.0.1:10808 HTTPS_PROXY=http://127.0.0.1:10808 claude";
    };
}
