{
  flake.modules.homeManager.browser-bookmarks =
    { lib, ... }:
    {
      options.browserBookmarks = lib.mkOption {
        readOnly = true;
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption { type = lib.types.str; };
              title = lib.mkOption { type = lib.types.str; };
              url = lib.mkOption { type = lib.types.str; };
            };
          }
        );
      };

      config.browserBookmarks = [
        {
          name = "vk";
          title = "VK";
          url = "https://vk.com";
        }
        {
          name = "yt";
          title = "YouTube";
          url = "https://youtube.com";
        }
        {
          name = "yts";
          title = "YouTube Subs";
          url = "https://www.youtube.com/feed/subscriptions";
        }
        {
          name = "gmail";
          title = "Gmail";
          url = "https://mail.google.com";
        }
        {
          name = "yamail";
          title = "Yandex Mail";
          url = "https://mail.yandex.ru";
        }
        {
          name = "gmap";
          title = "Google Maps";
          url = "https://www.google.com/maps";
        }
        {
          name = "yamap";
          title = "Яндекс Карты";
          url = "https://yandex.com/maps/65/novosibirsk/";
        }
        {
          name = "dmap";
          title = "2ГИС";
          url = "https://2gis.ru/novosibirsk";
        }
        {
          name = "gtrans";
          title = "Google Translate";
          url = "https://translate.google.com";
        }
        {
          name = "yatrans";
          title = "Яндекс Перевод";
          url = "https://translate.yandex.com";
        }
        {
          name = "grok";
          title = "Grok";
          url = "https://grok.com";
        }
        {
          name = "deepseek";
          title = "DeepSeek";
          url = "https://chat.deepseek.com";
        }
        {
          name = "gpt";
          title = "ChatGPT";
          url = "https://chatgpt.com";
        }
        {
          name = "zai";
          title = "z.ai";
          url = "https://z.ai";
        }
        {
          name = "claude";
          title = "Claude";
          url = "https://claude.ai";
        }
        {
          name = "gh";
          title = "GitHub";
          url = "https://github.com";
        }
        {
          name = "snix";
          title = "NixOS Packages";
          url = "https://search.nixos.org/packages";
        }
        {
          name = "snix-opt";
          title = "NixOS Options";
          url = "https://search.nixos.org/options";
        }
        {
          name = "shm";
          title = "Home Manager Options";
          url = "https://home-manager-options.extranix.com";
        }
        {
          name = "smynix";
          title = "MyNixOS";
          url = "https://mynixos.com";
        }
        {
          name = "snixwiki";
          title = "NixOS Wiki";
          url = "https://wiki.nixos.org";
        }
        {
          name = "snixver";
          title = "Nix Package Versions";
          url = "https://lazamar.co.uk/nix-versions";
        }
      ];
    };
}
