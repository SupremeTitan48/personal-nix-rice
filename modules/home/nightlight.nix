{ pkgs, userConfig, ... }:
{
  services.wlsunset = {
    enable = true;
    latitude  = userConfig.latitude;
    longitude = userConfig.longitude;
    temperature = {
      day = 6500;
      night = 3500;
    };
  };
}
