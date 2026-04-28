{ inputs, ... }:
{
  flake.modules.homeManager.telegram =
    {
      config,
      pkgs,
      pkgs-stable,
      lib,
      ...
    }:
    let
      inherit (config.lib.stylix) colors;

      # Color relationships defined using computed lighter/darker/alpha variants
      # These are resolved at activation time by the walogram script
      constants = ''
        windowBg: color0;
        windowFg: color5;
        windowBgOver: color1;
        windowBgRipple: color2;
        windowFgOver: color5;
        windowSubTextFg: color5;
        windowSubTextFgOver: color4;
        windowBoldFg: color5;
        windowBoldFgOver: color5;
        windowActiveTextFg: color13;
        windowShadowFg: #000000;
        windowShadowFgFallback: color0;

        shadowFg: #0000001a;
        slideFadeOutBg: #00000000;
        slideFadeOutShadowFg: color0;

        imageBg: color0;
        imageBgTransparent: #ffffff;

        activeButtonBg: color13;
        activeButtonBgOver: color13;
        activeButtonBgRipple: color13;
        activeButtonFg: color0;
        activeButtonFgOver: color0;
        activeButtonSecondaryFg: color1;
        activeButtonSecondaryFgOver: color1;
        activeLineFg: color13;
        activeLineFgError: color8;

        lightButtonBg: color0;
        lightButtonBgOver: color1;
        lightButtonBgRipple: color2;
        lightButtonFg: color13;
        lightButtonFgOver: color13;

        attentionButtonFg: color8;
        attentionButtonFgOver: color8;
        attentionButtonBgOver: color1;
        attentionButtonBgRipple: color2;

        outlineButtonBg: color0;
        outlineButtonBgOver: color1;
        outlineButtonOutlineFg: color13;
        outlineButtonBgRipple: color2;

        menuBg: color1;
        menuBgOver: color2;
        menuBgRipple: color2;
        menuIconFg: color4;
        menuIconFgOver: color5;
        menuSubmenuArrowFg: color4;
        menuFgDisabled: color3;
        menuSeparatorFg: color2;

        scrollBarBg: color4;
        scrollBarBgOver: color4;
        scrollBg: #00000000;
        scrollBgOver: color1;

        smallCloseIconFg: color4;
        smallCloseIconFgOver: color5;
        radialFg: color5;
        radialBg: color2;
        placeholderFg: color3;
        placeholderFgActive: color4;
        inputBorderFg: color2;
        filterInputBorderFg: color13;
        filterInputInactiveBg: color1;
        checkboxFg: color4;
        sliderBgActive: color13;
        sliderBgInactive: color3;

        tooltipBg: color2;
        tooltipFg: color5;
        tooltipBorderFg: color3;

        titleBg: color1;
        titleShadow: #00000000;
        titleButtonFg: color4;
        titleButtonBgOver: color2;
        titleButtonFgOver: color5;
        titleButtonCloseBg: #00000000;
        titleButtonCloseBgOver: #e81123;
        titleButtonCloseFg: color4;
        titleButtonCloseFgOver: #ffffff;

        trayCounterBg: color8;
        trayCounterFg: color5;
        trayCounterBgMacInvert: color5;
        trayCounterFgMacInvert: color0;

        layerBg: #0000007f;
        cancelIconFg: color4;
        cancelIconFgOver: color5;
        boxBg: color1;
        boxTextFg: color5;
        boxTextFgGood: color11;
        boxTextFgError: color8;
        boxTitleFg: color5;
        boxTitleAdditionalFg: color3;
        boxTitleCloseFg: color4;
        boxTitleCloseFgOver: color5;
        boxSearchBg: color0;

        dialogsMenuIconFg: color3;
        dialogsMenuIconFgOver: color4;
        dialogsBg: color1;
        dialogsNameFg: color5;
        dialogsNameFgActive: color5;
        dialogsChatIconFg: color4;
        dialogsChatIconFgActive: color5;
        dialogsDateFg: color5;
        dialogsDateFgActive: color5;
        dialogsTextFg: color5;
        dialogsTextFgActive: color5;
        dialogsTextFgService: color7;
        dialogsTextFgServiceActive: color7;
        dialogsTextFgServiceOver: color7;
        dialogsDraftFg: color8;
        dialogsDraftFgActive: color9;
        dialogsVerifiedIconBg: color13;
        dialogsVerifiedIconFg: color0;
        dialogsSendingIconFg: color5;
        dialogsSendingIconFgActive: color4;
        dialogsSentIconFg:          color13;   // галочки в списке чатов (обычное состояние)
        dialogsSentIconFgActive:    color13;   // когда чат активный
        dialogsSentIconFgOver:      color13;   // при наведении

        historyOutIconFg:           color13;   // галочки внутри чата (исходящее сообщение)
        historyOutIconFgSelected:   color13;   // когда сообщение выделено
        dialogsUnreadBg: color13;
        dialogsUnreadBgMuted: color3;
        dialogsUnreadFg: color0;
        dialogsBgActive: colorLighter1_30;
        dialogsUnreadBgActive: color5;
        dialogsUnreadBgMutedActive: color4;
        dialogsUnreadFgActive: color1;
        dialogsVerifiedIconBgActive: color5;
        dialogsVerifiedIconFgActive: color1;
        dialogsPinnedIconFg: color3;
        dialogsPinnedIconFgActive: color5;
        dialogsNameFgOver: color5;
        dialogsTextFgOver: color5;
        dialogsDateFgOver: color5;
        dialogsBgOver: colorLighter1_20;

        historyScrollBarBg: color4;
        historyScrollBarBgOver: color4;
        historyScrollBg: #00000000;
        historyScrollBgOver: color1;

        msgInBg: color1;
        msgInBgSelected: color2;
        msgOutBg: color1;
        msgOutBgSelected: color2;
        msgSelectOverlay: color13;
        msgStickerOverlay: color2;
        msgInServiceFg: color13;
        msgInServiceFgSelected: color13;
        msgOutServiceFg: color13;
        msgOutServiceFgSelected: color13;
        msgInShadow: #00000000;
        msgInShadowSelected: #00000000;
        msgOutShadow: #00000000;
        msgOutShadowSelected: #00000000;
        msgInDateFg: color3;
        msgInDateFgSelected: color4;
        msgOutDateFg: color3;
        msgOutDateFgSelected: color4;
        msgServiceFg: color5;
        msgServiceBg: color2;
        msgServiceBgSelected: color3;
        msgInReplyBarColor: color13;
        msgInReplyBarSelColor: color13;
        msgOutReplyBarColor: color13;
        msgOutReplyBarSelColor: color13;
        msgImgReplyBarColor: color5;
        msgInMonoFg: color12;
        msgOutMonoFg: color12;
        msgDateImgFg: color5;
        msgDateImgBg: #00000054;
        msgDateImgBgOver: #00000074;

        msgFileThumbLinkInFg: color13;
        msgFileThumbLinkInFgSelected: color12;
        msgFileThumbLinkOutFg: color13;
        msgFileThumbLinkOutFgSelected: color12;
        msgFileInBg: color13;
        msgFileInBgOver: color12;
        msgFileInBgSelected: color11;
        msgFileOutBg: color13;
        msgFileOutBgOver: color12;
        msgFileOutBgSelected: color11;
        msgFile1Bg: color13;
        msgFile1BgDark: color14;
        msgFile1BgOver: color12;
        msgFile1BgSelected: color11;
        msgFile2Bg: color11;
        msgFile2BgDark: color12;
        msgFile2BgOver: color10;
        msgFile2BgSelected: color11;
        msgFile3Bg: color8;
        msgFile3BgDark: color14;
        msgFile3BgOver: color9;
        msgFile3BgSelected: color8;
        msgFile4Bg: color10;
        msgFile4BgDark: color9;
        msgFile4BgOver: color10;
        msgFile4BgSelected: color10;

        historySendingOutIconFg: color3;
        historySendingInIconFg: color3;
        historySendingInvertedIconFg: color5;
        historyCallArrowInFg: color11;
        historyCallArrowInFgSelected: color11;
        historyCallArrowMissedInFg: color8;
        historyCallArrowMissedInFgSelected: color8;
        historyCallArrowOutFg: color11;
        historyCallArrowOutFgSelected: color11;
        historyUnreadBarBg: color2;
        historyUnreadBarBorder: color3;
        historyUnreadBarFg: color4;
        historyForwardChooseBg: color2;
        historyForwardChooseFg: color5;

        historyPeer1UserpicBg: color8;
        historyPeer2UserpicBg: color9;
        historyPeer3UserpicBg: color10;
        historyPeer4UserpicBg: color11;
        historyPeer5UserpicBg: color12;
        historyPeer6UserpicBg: color13;
        historyPeer7UserpicBg: color14;
        historyPeer8UserpicBg: color15;

        historyComposeAreaBg: color1;
        historyComposeAreaFgService: color13;
        historyComposeIconFg: color4;
        historyComposeIconFgOver: color5;
        historySendIconFg: color13;
        historySendIconFgOver: color13;
        historyPinnedBg: color1;
        historyReplyBg: color1;
        historyReplyIconFg: color13;
        historyReplyCancelFg: color4;
        historyReplyCancelFgOver: color5;

        profileStatusFgOver: color4;
        profileVerifiedCheckBg: color13;
        profileVerifiedCheckFg: color0;
        profileAdminStartFg: color10;

        notificationBg: color1;

        mainMenuBg: color1;
        mainMenuCoverBg: color13;
        mainMenuCoverFg: color0;

        mediaPlayerBg: color1;
        mediaPlayerActiveFg: color13;
        mediaPlayerInactiveFg: color4;
        mediaPlayerDisabledFg: color3;

        overviewCheckFg: color4;
        overviewCheckFgActive: color13;
        overviewPhotoSelectOverlay: color13;

        callBg: color0;
        callNameFg: color5;
        callStatusFg: color4;
        callIconFg: color5;
        callAnswerBg: color11;
        callHangupBg: color8;
        callCancelBg: color2;
        callCancelFg: color5;

        topBarBg: color1;

        sideBarBg: color0;
        sideBarBgActive: colorLighter0_30;
        sideBarBgRipple: color1;
        sideBarTextFg: color4;
        sideBarTextFgActive: color5;
        sideBarIconFg: color4;
        sideBarIconFgActive: color5;
        sideBarBadgeBg: color13;
        sideBarBadgeBgMuted: color3;
        sideBarBadgeFg: color0;
      '';
      walogram = pkgs.writeShellApplication {
        name = "walogram";
        runtimeInputs = with pkgs-stable; [
          file
          zip
          imagemagick
        ];
        bashOptions = [ "pipefail" ];
        excludeShellChecks = [ "SC2034" ];
        text = ''
          tempdir="$(mktemp -d)"
          cachedir="${config.xdg.cacheHome}/stylix-telegram-theme"
          themename="stylix.tdesktop-theme"
          mkdir -p "$cachedir"

          gencolors() {
            colors="0 1 2 3 4 5 7 8 9 10 11 12 13 14 15"
            divisions="10 20 30 40 50 60 70 80 90"
            alphas="00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff"

            for i in $colors; do
              color="color$i"
              c_rgb_12d=$((0x"''${!color:1:2}"))
              c_rgb_34d=$((0x"''${!color:3:2}"))
              c_rgb_56d=$((0x"''${!color:5:2}"))

              for division in $divisions; do
                c_r=$((c_rgb_12d + (c_rgb_12d * (division / 10) / 10)))
                c_g=$((c_rgb_34d + (c_rgb_34d * (division / 10) / 10)))
                c_b=$((c_rgb_56d + (c_rgb_56d * (division / 10) / 10)))
                [ "$c_r" -ge 255 ] && c_r=255
                [ "$c_g" -ge 255 ] && c_g=255
                [ "$c_b" -ge 255 ] && c_b=255
                c_hex_r="$(printf "%02x" "$c_r")"
                c_hex_g="$(printf "%02x" "$c_g")"
                c_hex_b="$(printf "%02x" "$c_b")"
                eval "color''${i}_lighter_''${division}=#''${c_hex_r}''${c_hex_g}''${c_hex_b}"

                c_r=$((c_rgb_12d - (c_rgb_12d * (division / 10) / 10)))
                c_g=$((c_rgb_34d - (c_rgb_34d * (division / 10) / 10)))
                c_b=$((c_rgb_56d - (c_rgb_56d * (division / 10) / 10)))
                c_hex_r="$(printf "%02x" "$c_r")"
                c_hex_g="$(printf "%02x" "$c_g")"
                c_hex_b="$(printf "%02x" "$c_b")"
                eval "color''${i}_darker_''${division}=#''${c_hex_r}''${c_hex_g}''${c_hex_b}"
              done
            done

            for i in $colors; do
              echo "color$i: $(eval "echo \"\$color''${i}\"");"
              for division in $divisions; do
                echo "colorLighter''${i}_''${division}: $(eval "echo \"\$color''${i}_lighter_''${division}\"");"
                echo "colorDarker''${i}_''${division}: $(eval "echo \"\$color''${i}_darker_''${division}\"");"
              done
              for alpha in $alphas; do
                c="$(eval "echo \"\$color''${i}\"")"
                echo "colorAlpha''${i}_''${alpha}: ''${c}''${alpha};"
              done
            done
          }

          gentheme() {
            walname="background.jpg"
            printf '%s' '${constants}' > "$tempdir/constants"
            trap 'rm -rf "$tempdir"; exit 0' INT TERM EXIT
            gencolors | cat - "$tempdir/constants" > "$tempdir/colors.tdesktop-theme"
            magick -size 1920x1080 "xc:$color0" "$tempdir/$walname"
            zip -jq -FS "$cachedir/$themename" "$tempdir"/*
          }

          color0="#${colors.base00}"
          color1="#${colors.base01}"
          color2="#${colors.base02}"
          color3="#${colors.base03}"
          color4="#${colors.base04}"
          color5="#${colors.base05}"
          color6="#${colors.base06}"
          color7="#${colors.base07}"
          color8="#${colors.base08}"
          color9="#${colors.base09}"
          color10="#${colors.base0A}"
          color11="#${colors.base0B}"
          color12="#${colors.base0C}"
          color13="#${colors.base0D}"
          color14="#${colors.base0E}"
          color15="#${colors.base0F}"

          gentheme
        '';
      };
    in
    {
      home.packages = [ pkgs-stable.ayugram-desktop ];

      home.activation.tg-theme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe walogram}
      '';
    };
}
