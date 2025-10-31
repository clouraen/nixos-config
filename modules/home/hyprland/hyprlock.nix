{ host, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
        fractional_scaling = 0;
      };

      background = [
        {
          path = "${../../../wallpapers/wallpaper.png}";

          color = "rgba(6, 8, 20, 255)";
          blur_passes = 3;
          vibrancy_darkness = 0.15;
        }
      ];

      shape = [
        # User box
        {
          size = "300, 50";

          rounding = 0;
          border_size = 3;
          color = "rgba(15, 20, 46, 0.65)";
          border_color = "rgba(0, 245, 255, 0.9)";

          position = "0, ${if host == "laptop" then "120" else "270"}";
          halign = "center";
          valign = "bottom";
        }
      ];

      label = [
        # Time
        {
          text = ''cmd[update:1000] echo "$(date +'%k:%M')"'';

          font_size = 115;
          font_family = "Maple Mono Bold";

          shadow_passes = 3;
          color = "rgba(0, 245, 255, 0.9)";

          position = "0, ${if host == "laptop" then "-25" else "-150"}";
          halign = "center";
          valign = "top";
        }
        # Date
        {
          text = ''cmd[update:1000] echo "- $(date +'%A, %B %d') -" '';

          font_size = 18;
          font_family = "Maple Mono";

          shadow_passes = 3;
          color = "rgba(255, 0, 140, 0.8)";

          position = "0, ${if host == "laptop" then "-225" else "-350"}";
          halign = "center";
          valign = "top";
        }
        # Username
        {
          text = "  $USER";

          font_size = 15;
          font_family = "Maple Mono Bold";

          color = "rgba(0, 245, 255, 1)";

          position = "0, ${if host == "laptop" then "134" else "284"}";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          size = "300, 50";
          rounding = 0;
          outline_thickness = 3;

          dots_spacing = 0.4;

          font_color = "rgba(0, 245, 255, 0.95)";
          font_family = "Maple Mono Bold";

          outer_color = "rgba(0, 245, 255, 0.9)";
          inner_color = "rgba(16, 0, 32, 0.6)";
          check_color = "rgba(255, 0, 140, 0.95)";
          fail_color = "rgba(255, 64, 64, 0.95)";
          capslock_color = "rgba(255, 111, 0, 0.95)";
          bothlock_color = "rgba(255, 111, 0, 0.95)";

          hide_input = false;
          fade_on_empty = false;
          placeholder_text = ''<i><span foreground="##00f5ff">ENTER ACCESS CODE</span></i>'';

          position = "0, ${if host == "laptop" then "50" else "200"}";
          halign = "center";
          valign = "bottom";
        }
      ];

      animation = [ "inputFieldColors, 0" ];
    };
  };
}
