{ inputs, ... }:
{
  flake.modules.homeManager.zen =
    { pkgs, ... }:
    let
      zen-pkg = inputs.zen-browser.packages.x86_64-linux.default;
      policies = builtins.toJSON {
        policies = {
          DisableAppUpdate = true;
          Preferences = {
            "zen.view.compact" = {
              Value = true;
              Status = "default";
            };
            "zen.view.compact.hide-tabbar" = {
              Value = true;
              Status = "default";
            };
          };
        };
      };
      zen-wrapped = pkgs.symlinkJoin {
        name = "zen-browser";
        paths = [ zen-pkg ];
        postBuild = ''
          rm -rf $out/lib/zen-bin-*/distribution/policies.json
          for dir in $out/lib/zen-bin-*/distribution; do
            echo '${policies}' > "$dir/policies.json"
          done
        '';
      };
    in
    {
      home.packages = [ zen-wrapped ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "zen-beta.desktop";
          "x-scheme-handler/http" = "zen-beta.desktop";
          "x-scheme-handler/https" = "zen-beta.desktop";
        };
      };
    };
}
