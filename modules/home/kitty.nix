{ host, ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "Maple Mono";
      size = if (host == "laptop") then 15 else 16;
    };

    extraConfig = ''
      font_features MapleMono-Regular +ss01 +ss02 +ss04
      font_features MapleMono-Bold +ss01 +ss02 +ss04
      font_features MapleMono-Italic +ss01 +ss02 +ss04
      font_features MapleMono-Light +ss01 +ss02 +ss04

      background #050417
      foreground #E0F7FF
      selection_background #1A103F
      selection_foreground #E0F7FF
      cursor #00F5FF
      cursor_text_color #050417
      url_color #FF008C
      active_border_color #FF008C
      inactive_border_color #081020
      bell_border_color #FF6F00
      tab_bar_background #050417

      color0  #080414
      color1  #FF2D96
      color2  #00FFC6
      color3  #FFB400
      color4  #7B5CFF
      color5  #FF008C
      color6  #00F5FF
      color7  #E0F7FF
      color8  #10143A
      color9  #FF4FB3
      color10 #4CFFDB
      color11 #FFDF5E
      color12 #A98DFF
      color13 #FF56C8
      color14 #5CFBFF
      color15 #FFFFFF
    '';

    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.75";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      window_padding_width = if (host == "laptop") then 5 else 10;

      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";
      active_tab_foreground = "#050417";
      active_tab_background = "#00F5FF";
      inactive_tab_foreground = "#E0F7FF";
      inactive_tab_background = "#10143A";
    };

    keybindings = {
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";

      ## Unbind
      "ctrl+shift+left" = "no_op";
      "ctrl+shift+right" = "no_op";
    };
  };
}
