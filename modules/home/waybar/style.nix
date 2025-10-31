{ ... }:
let
  custom = {
    font = "Maple Mono";
    font_size = "18px";
    font_weight = "bold";
    text_color = "#E0F7FF";
    background_0 = "rgba(5, 4, 20, 0.92)";
    background_1 = "rgba(9, 2, 24, 0.8)";
    border_color = "#00F5FF";
    accent_cyan = "#00F5FF";
    accent_magenta = "#FF008C";
    accent_purple = "#7B5CFF";
    accent_orange = "#FF6F00";
    glow = "0 0 12px rgba(0, 245, 255, 0.45)";
    opacity = "1";
    indicator_height = "2px";
  };
in
{
  programs.waybar.style = with custom; ''
    * {
      border: none;
      border-radius: 0px;
      padding: 0;
      margin: 0;
      font-family: ${font};
      font-weight: ${font_weight};
      opacity: ${opacity};
      font-size: ${font_size};
    }

    window#waybar {
      background: linear-gradient(90deg, rgba(5, 4, 20, 0.92) 0%, rgba(12, 0, 45, 0.75) 100%);
      border-top: 1px solid ${border_color};
      box-shadow: ${glow};
    }

    tooltip {
      background: ${background_1};
      border: 1px solid ${border_color};
      box-shadow: ${glow};
    }
    tooltip label {
      margin: 5px;
      color: ${text_color};
    }

    #workspaces {
      padding-left: 15px;
    }
    #workspaces button {
      color: ${accent_purple};
      padding-left:  5px;
      padding-right: 5px;
      margin-right: 10px;
      background: transparent;
      border-bottom: 2px solid transparent;
    }
    #workspaces button.empty {
      color: ${text_color};
    }
    #workspaces button.active {
      color: ${accent_cyan};
      border-bottom: 2px solid ${accent_magenta};
    }

    #clock {
      color: ${text_color};
      text-shadow: ${glow};
    }

    #tray {
      margin-left: 10px;
      color: ${text_color};
      text-shadow: ${glow};
    }
    #tray menu {
      background: ${background_1};
      border: 1px solid ${border_color};
      padding: 8px;
    }
    #tray menuitem {
      padding: 1px;
    }

    #pulseaudio, #network, #cpu, #memory, #disk, #battery, #language, #custom-notification, #custom-power-menu {
      padding-left: 12px;
      padding-right: 12px;
      margin-right: 14px;
      color: ${text_color};
      background: rgba(12, 0, 45, 0.55);
      border-radius: 12px;
      border: 1px solid rgba(0, 245, 255, 0.25);
      box-shadow: ${glow};
    }

    #pulseaudio, #language, #custom-notification {
      margin-left: 15px;
    }

    #custom-power-menu {
      padding-right: 6px;
      margin-right: 9px;
      border: 1px solid ${accent_magenta};
    }

    #custom-launcher {
      font-size: 22px;
      color: ${accent_cyan};
      font-weight: bold;
      margin-left: 18px;
      padding-right: 12px;
      text-shadow: ${glow};
    }
  '';
}
