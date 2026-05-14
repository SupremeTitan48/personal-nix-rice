# modules/nixos/auto-upgrade.nix — continuous deployment via system.autoUpgrade.
#
# When repoUrl is set in user-config.nix, a systemd timer pulls from GitHub
# every hour and runs `nixos-rebuild switch`. A failed build is rolled back
# automatically by NixOS; the running system is never left half-configured.
#
# Requirements:
#   • The GitHub repo must be public (or the system must have SSH access).
#   • CI (GitHub Actions) must gate merges to main so broken configs never land.
#   • Set repoUrl = "" in user-config.nix to disable auto-upgrade entirely.
{ lib, userConfig, ... }:
{
  system.autoUpgrade = lib.mkIf (userConfig.repoUrl != "") {
    enable = true;

    # Pull the flake directly from GitHub — no local clone needed.
    flake = "${userConfig.repoUrl}#desktop";

    # Also update flake inputs (nixpkgs, hyprland, etc.) on each run so the
    # system stays current with upstream fixes.
    flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];

    # Run once per hour; random delay spreads load if multiple machines share
    # the same repo.
    dates = "hourly";
    randomizedDelaySec = "5min";

    # Do NOT reboot automatically — the user controls when to reboot.
    # Set to true if you want kernel/firmware updates to apply immediately.
    allowReboot = false;
  };
}
