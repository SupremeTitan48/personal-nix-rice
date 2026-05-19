# modules/home/hyprland/animations.nix
#
# Bezier curves sourced from end-4/dots-hyprland (general.lua) and
# JaKooLit/Hyprland-Dots (END-4.conf) — Material Design 3 motion spec.
# No borderangle loop (removed — looks cheap; border stays a static gradient).
{ ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    animations {
      enabled = true

      # ── Material Design 3 curves ───────────────────────────────────────
      bezier = md3_decel,  0.05, 0.7,  0.1,  1      # standard decelerate
      bezier = md3_accel,  0.3,  0,    0.8,  0.15   # standard accelerate
      bezier = menu_decel, 0.1,  1,    0,    1       # menu/layer open
      bezier = menu_accel, 0.38, 0.04, 1,    0.07   # menu/layer close
      bezier = overshot,   0.05, 0.9,  0.1,  1.1    # slight overshoot

      # ── Windows ────────────────────────────────────────────────────────
      # popin 60% = scale from 60% → 100% on open (feels snappy, not jarring)
      animation = windows,     1, 3, md3_decel, popin 60%
      animation = windowsIn,   1, 3, md3_decel, popin 60%
      animation = windowsOut,  1, 3, md3_accel, popin 60%
      animation = windowsMove, 1, 3, md3_decel

      # ── Borders (static gradient, no rotating loop) ────────────────────
      animation = border, 1, 10, default

      # ── Layers (Quickshell popups and shell surfaces) ─────────────────
      animation = layers,         1, 3, menu_decel, slide
      animation = layersIn,       1, 3, menu_decel, slide
      animation = layersOut,      1, 2, menu_accel

      # ── Fade ───────────────────────────────────────────────────────────
      animation = fade, 1, 3, md3_decel

      # ── Workspaces ─────────────────────────────────────────────────────
      animation = workspaces,       1, 7, menu_decel, slide
      animation = specialWorkspace, 1, 3, md3_decel,  slidevert
    }
  '';
}
