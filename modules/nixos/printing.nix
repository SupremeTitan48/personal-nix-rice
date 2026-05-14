# modules/nixos/printing.nix — CUPS printing + mDNS network printer discovery
{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    # Gutenprint covers most consumer/laser printers. Add pkgs.hplip for HP-specific models.
    drivers = with pkgs; [ gutenprint gutenprintBin ];
  };

  # Avahi (mDNS) lets CUPS auto-discover network printers — AirPrint, IPP, etc.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = [ pkgs.system-config-printer ];
}
