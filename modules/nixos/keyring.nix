# modules/nixos/keyring.nix — GNOME Keyring for SSH agent and libsecret
#
# Unlocked automatically at SDDM login via PAM. Provides:
#   • D-Bus Secret Service (Chrome saved passwords, app tokens, git credentials)
#   • SSH agent (auto-unlocks SSH key passphrases on first use per session)
{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # seahorse: GUI to view/edit stored secrets and SSH keys
  environment.systemPackages = [ pkgs.seahorse ];
}
