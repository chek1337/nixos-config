{ ... }:
{
  flake.modules.homeManager.claude-squad =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.buildGoModule {
          pname = "claude-squad";
          version = "1.0.19";
          src = pkgs.fetchFromGitHub {
            owner = "smtg-ai";
            repo = "claude-squad";
            rev = "v1.0.19";
            hash = "sha256-9XjixCztPh+VdiFmYWPMC6Cnh2EH70L4eDknteurCkA=";
          };
          vendorHash = "sha256-0EFCao5l9BNX6zdHVziV9ZwJX9v+BNu+e3tcFtYrDJ4=";
          doCheck = false;
          nativeBuildInputs = [ pkgs.git ];
          meta = {
            description = "Manage multiple AI agents like Claude Code, Aider, Codex, and Amp";
            homepage = "https://github.com/smtg-ai/claude-squad";
            license = pkgs.lib.licenses.mit;
            mainProgram = "claude-squad";
          };
        })
      ];
    };
}
