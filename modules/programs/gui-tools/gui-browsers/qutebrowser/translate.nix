{
  flake.modules.homeManager.qutebrowser-translate =
    { pkgs, config, ... }:
    let
      # auto-detected source language, translate into this language
      targetLang = "ru";

      colors = config.lib.stylix.colors;

      # Selected-text translation: hits the public Google Translate endpoint
      # (no API key) and injects a floating, Stylix-themed popup over the page
      # via the qute IPC fifo instead of using the cramped status-bar message.
      # Dismiss the popup by clicking outside it or pressing Escape.
      # `--url` mode opens the whole current page through Google Translate.
      translateScript =
        pkgs.writeScript "qute-translate" # py
          ''
            #!${pkgs.python3}/bin/python3
            import os
            import sys
            import json
            import urllib.parse
            import urllib.request

            TARGET = "${targetLang}"

            def popup_js(text):
                msg = urllib.parse.quote(text)
                return (
                    "(function(){"
                    "var id=\"qute-translate-box\";"
                    "var old=document.getElementById(id); if(old) old.remove();"
                    "var box=document.createElement(\"div\");"
                    "box.id=id;"
                    "box.style.position=\"fixed\";"
                    "box.style.bottom=\"16px\";"
                    "box.style.right=\"16px\";"
                    "box.style.maxWidth=\"420px\";"
                    "box.style.maxHeight=\"60vh\";"
                    "box.style.overflow=\"auto\";"
                    "box.style.whiteSpace=\"pre-wrap\";"
                    "box.style.background=\"#${colors.base00}\";"
                    "box.style.color=\"#${colors.base05}\";"
                    "box.style.border=\"2px solid #${colors.base0D}\";"
                    "box.style.borderRadius=\"8px\";"
                    "box.style.padding=\"12px 14px\";"
                    "box.style.fontSize=\"15px\";"
                    "box.style.lineHeight=\"1.4\";"
                    "box.style.fontFamily=\"sans-serif\";"
                    "box.style.boxShadow=\"0 4px 16px rgba(0,0,0,0.4)\";"
                    "box.style.zIndex=\"2147483647\";"
                    "box.textContent=decodeURIComponent(\"" + msg + "\");"
                    "document.body.appendChild(box);"
                    "function close(e){ if(!box.contains(e.target)){ box.remove(); cleanup(); } }"
                    "function key(e){ if(e.key===\"Escape\"){ box.remove(); cleanup(); } }"
                    "function cleanup(){"
                    " document.removeEventListener(\"mousedown\",close);"
                    " document.removeEventListener(\"keydown\",key); }"
                    "setTimeout(function(){"
                    " document.addEventListener(\"mousedown\",close);"
                    " document.addEventListener(\"keydown\",key); },0);"
                    "})();"
                )

            def translate(text):
                q = urllib.parse.quote(text)
                url = (
                    "https://translate.googleapis.com/translate_a/single"
                    "?client=gtx&sl=auto&tl=" + TARGET + "&dt=t&q=" + q
                )
                req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(req, timeout=10) as r:
                    data = json.loads(r.read().decode("utf-8"))
                return "".join(seg[0] for seg in data[0] if seg[0])

            def main():
                fifo = os.getenv("QUTE_FIFO")
                if not fifo:
                    sys.exit("qute-translate: must be run as a qutebrowser userscript")
                if "--url" in sys.argv[1:]:
                    cur = urllib.parse.quote(os.getenv("QUTE_URL", ""))
                    tgt = (
                        "https://translate.google.com/translate?sl=auto&tl="
                        + TARGET + "&u=" + cur
                    )
                    cmd = "open -t " + tgt
                else:
                    text = os.getenv("QUTE_SELECTED_TEXT", "").strip()
                    if not text:
                        body = "qute-translate: nothing selected"
                    else:
                        try:
                            body = translate(text)
                        except Exception as exc:
                            body = "qute-translate error: " + str(exc)
                    cmd = "jseval -q " + popup_js(body).replace(chr(10), " ")
                with open(fifo, "a") as f:
                    f.write(cmd + chr(10))

            if __name__ == "__main__":
                main()
          '';
    in
    {
      xdg.dataFile."qutebrowser/userscripts/qute-translate".source = translateScript;

      programs.qutebrowser.extraConfig = # py
        ''
          # ,t  — translate selected text, show it in a floating popup over the page
          config.bind(",t", "spawn --userscript qute-translate")
          # ,T  — open the whole current page through Google Translate (new tab)
          config.bind(",T", "spawn --userscript qute-translate --url")
        '';
    };
}
