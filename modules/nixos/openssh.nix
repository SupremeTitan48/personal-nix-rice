# modules/nixos/openssh.nix — remote login for Cursor Remote SSH and admin access.
#
# Public keys live in user-config.nix (sshPublicKeys). Password login stays
# enabled only while that list is empty so you can bootstrap from the machine
# console, add your key, push, and rebuild to lock it down.
{ lib, userConfig, ... }:
let
  hasKeys = userConfig.sshPublicKeys != [ ];
in
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = !hasKeys;
    };
  };

  users.users.${userConfig.username}.openssh.authorizedKeys.keys =
    userConfig.sshPublicKeys;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
