{ ... }:
{
  flake.modules.nixos.kanata =
    { config, ... }:
    {
      services.kanata = {
        enable = true;
        keyboards.internalKeyboard = {
          # Per-host device path(s); [] = auto-detect all keyboards.
          devices = config.settings.kanataKeyboardDevices;

          # defsrc only lists homerow keys; let everything else pass through.
          extraDefCfg = "process-unmapped-keys yes";

          # Homerow mods, order meta/alt/shift/ctrl:
          #   left  a s d f -> Super Alt Shift Ctrl
          #   right j k l ; -> Ctrl Shift Alt Super (mirrored)
          config = ''
            (defsrc
              a s d f j k l ;
            )
            (defvar
              tap-time 200
              hold-time 200
            )
            (defalias
              a (tap-hold-release $tap-time $hold-time a lmet)
              s (tap-hold-release $tap-time $hold-time s lalt)
              d (tap-hold-release $tap-time $hold-time d lsft)
              f (tap-hold-release $tap-time $hold-time f lctl)
              j (tap-hold-release $tap-time $hold-time j rctl)
              k (tap-hold-release $tap-time $hold-time k rsft)
              l (tap-hold-release $tap-time $hold-time l ralt)
              ; (tap-hold-release $tap-time $hold-time ; rmet)
            )
            (deflayer base
              @a @s @d @f @j @k @l @;
            )
          '';
        };
      };
    };
}
