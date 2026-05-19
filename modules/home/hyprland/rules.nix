# modules/home/hyprland/rules.nix
# Hyprland 0.47+ windowrule format:
#   windowrule = EFFECT VALUE, match:PROP REGEX
# All effects need explicit values; filters use match: prefix.
{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    # Prevent apps from randomly maximizing themselves
    windowrule = suppress_event maximize, match:class .*

    # Picture-in-Picture floating
    windowrule = float true, match:title Picture-in-Picture
    windowrule = keep_aspect_ratio true, match:title Picture-in-Picture
    windowrule = pin true, match:title Picture-in-Picture

    # Float file pickers and dialogs
    windowrule = float true, match:class xdg-desktop-portal.*
    windowrule = float true, match:title Open File.*
    windowrule = float true, match:title Select a File.*
    windowrule = float true, match:title Choose wallpaper.*
    windowrule = float true, match:class bluedevil
    windowrule = float true, match:class pavucontrol.*

    # Fix Chrome file picker
    windowrule = float true, match:class google-chrome, match:title Open Files?

    # Slight transparency for terminals
    windowrule = opacity 0.95 0.9, match:class foot.*

    # Gaming: no blur, no rounding for performance
    windowrule = no_blur true, match:class steam_app_.*
    windowrule = no_anim true, match:class steam_app_.*
    windowrule = no_shadow true, match:class steam_app_.*
    windowrule = rounding 0, match:class steam_app_.*
    windowrule = immediate true, match:class steam_app_.*

    # Steam main window
    windowrule = float true, match:class steam, match:title Steam Settings
    windowrule = float true, match:class steam, match:title Friends List

    # Gamescope: fullscreen, no decoration, immediate present
    windowrule = fullscreen true, match:class gamescope
    windowrule = no_blur true, match:class gamescope
    windowrule = no_shadow true, match:class gamescope
    windowrule = rounding 0, match:class gamescope
    windowrule = immediate true, match:class gamescope

    # Idle inhibit for fullscreen windows and games
    windowrule = idle_inhibit fullscreen, match:fullscreen 1
    windowrule = idle_inhibit fullscreen, match:class steam_app_.*
    windowrule = idle_inhibit fullscreen, match:class gamescope

    # Obsidian: slight transparency
    windowrule = opacity 0.97 0.95, match:class obsidian

    # Claude desktop
    windowrule = opacity 0.97 0.95, match:class claude
    windowrule = float true, match:class claude, match:title .*Preferences.*

    # Sidra (Apple Music client)
    windowrule = float true, match:class sidra
    windowrule = center true, match:class sidra
    windowrule = size 60% 70%, match:class sidra
    windowrule = opacity 0.97 0.93, match:class sidra

    # nwg-look
    windowrule = float true, match:class nwg-look
    windowrule = center true, match:class nwg-look

    # Mission Center
    windowrule = float true, match:class io.missioncenter.MissionCenter

    # Bitwarden
    windowrule = float true, match:class Bitwarden, match:title .*Bitwarden.*

    # GNOME Disk Utility
    windowrule = float true, match:class gnome-disks
    windowrule = size 70% 70%, match:class gnome-disks
    windowrule = center true, match:class gnome-disks

    # OBS Studio
    windowrule = float true, match:class com.obsproject.Studio, match:title .*Properties.*
    windowrule = float true, match:class com.obsproject.Studio, match:title .*Settings.*
    windowrule = float true, match:class com.obsproject.Studio, match:title .*Filters.*

    # Seahorse (keyring manager)
    windowrule = float true, match:class seahorse
    windowrule = size 60% 65%, match:class seahorse
    windowrule = center true, match:class seahorse

    # Default workspace
    workspace = 1, default:true
  '';
}
