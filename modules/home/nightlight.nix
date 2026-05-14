{ pkgs, ... }:
{
  services.wlsunset = {
    enable = true;
    latitude = "41.8";
    longitude = "-87.6";
    temperature = {
      day = 6500;
      night = 3500;
    };
  };
}
