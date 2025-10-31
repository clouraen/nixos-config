{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us,fr";
      kb_options = "grp:alt_caps_toggle";
      numlock_by_default = true;
      repeat_delay = 300;
      follow_mouse = 0;
      float_switch_override_focus = 0;
      mouse_refocus = 0;
      sensitivity = 0;
      touchpad = {
        natural_scroll = true;
      };
    };

    general = {
      "$mainMod" = "SUPER";
      layout = "dwindle";
      gaps_in = 8;
      gaps_out = 16;
      border_size = 3;
      "col.active_border" = "rgb(00F5FF) rgb(FF008C) 45deg";
      "col.inactive_border" = "rgba(24, 8, 32, 0.65)";
      border_part_of_window = false;
      no_border_on_floating = false;
    };

    misc = {
      disable_hyprland_logo = true;
      always_follow_on_dnd = true;
      layers_hog_keyboard_focus = true;
      animate_manual_resizes = false;
      enable_swallow = true;
      focus_on_activate = true;
      new_window_takes_over_fullscreen = 2;
      middle_click_paste = false;
    };

    dwindle = {
      force_split = 2;
      special_scale_factor = 1.0;
      split_width_multiplier = 1.0;
      use_active_for_splits = true;
      pseudotile = "yes";
      preserve_split = "yes";
    };

    master = {
      new_status = "master";
      special_scale_factor = 1;
    };

    decoration = {
      rounding = 12;
      active_opacity = 0.94;
      inactive_opacity = 0.85;
      fullscreen_opacity = 1.0;

      blur = {
        enabled = true;
        size = 7;
        passes = 3;
        brightness = 1.25;
        contrast = 1.6;
        ignore_opacity = true;
        noise = 0.015;
        new_optimizations = true;
        xray = true;
        vibrancy = 0.25;
        vibrancy_darkness = 0.0;
      };

      shadow = {
        enabled = true;

        ignore_window = true;
        offset = "0 6";
        range = 30;
        render_power = 4;
        color = "rgba(8, 255, 214, 0.35)";
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "neonPulse, 0.19, 0.47, 0.32, 1"
        "neonGlide, 0.11, 0.9, 0.15, 1"
        "fade_curve, 0, 0.55, 0.45, 1"
      ];

      animation = [
        "windowsIn,   1, 5, neonGlide, popin 40%"
        "windowsOut,  1, 5, neonPulse, popin 80%"
        "windowsMove, 1, 3, neonPulse, slide"
        "fadeIn,      1, 6, fade_curve"
        "fadeOut,     1, 6, fade_curve"
        "fadeShadow,  1, 12, neonPulse"
        "fadeDim,     1, 5, neonPulse"
        "workspaces,  1, 5, neonGlide, slidefade"
      ];
    };

    xwayland = {
      force_zero_scaling = true;
    };
  };
}
