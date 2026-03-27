{ ... }:
{
  flake.modules.homeManager.mangohud =
    { lib, ... }:
    {
      programs.mangohud = {
        enable = true;
        settings = {
          fps = true;
          cpu_stats = true;
          cpu_temp = true;
          gpu_stats = true;
          gpu_temp = true;
          frame_timing = false;
          font_size = lib.mkForce 12;
          position = "top-left";
          offset_x = 1;
          offset_y = 1;
          background_alpha = lib.mkForce 0;
          alpha = lib.mkForce 1;
          gamemode = true;
          toggle_hud = "Shift_R+F12";
        };
      };
    };
}
