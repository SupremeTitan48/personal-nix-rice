# user-config.nix — the ONLY file you need to edit before your first build.
# Run ./install.sh to fill this in interactively, or edit manually.
{
  # ── Identity ────────────────────────────────────────────────────────────────
  # Your Linux username (lowercase, no spaces). A home directory and system
  # user will be created with this name.
  username = "jkoch";

  # Git identity
  gitName  = "Jackson Koch";
  gitEmail = "jacksongkoch@icloud.com";

  # ── Locale ──────────────────────────────────────────────────────────────────
  # Full TZ name from: timedatectl list-timezones
  timezone = "America/Chicago";

  # Decimal latitude / longitude for the night-light (blue-light filter).
  # Look yours up at https://latlong.net — west longitudes are negative.
  latitude  = "41.8";
  longitude = "-87.6";

  # ── Display ─────────────────────────────────────────────────────────────────
  # Hyprland monitor string: "CONNECTOR,WIDTHxHEIGHT@REFRESH,POSITIONxY,SCALE"
  # Find your connector after first boot: hyprctl monitors  OR  wlr-randr
  # Examples:
  #   "DP-1,2560x1440@240,0x0,1"      ← 1440p 240 Hz DisplayPort
  #   "HDMI-A-1,1920x1080@60,0x0,1"   ← 1080p 60 Hz HDMI
  monitor = ",highres,auto,1";

  # ── GPU ─────────────────────────────────────────────────────────────────────
  # Use the NVIDIA open kernel module?
  #   true  → RTX 30xx (Ampere) and newer only — best Wayland performance
  #   false → GTX / RTX 20xx / older — use the proprietary module instead
  nvidiaOpen = true;

  # ── CD — continuous deployment ──────────────────────────────────────────────
  # Your GitHub repo in "github:owner/repo" form.
  # The auto-upgrade systemd timer pulls from here every hour.
  # Set to "" to disable auto-upgrade.
  repoUrl = "github:SupremeTitan48/personal-nix-rice";
}
