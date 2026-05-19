{ config, pkgs, lib, inputs, userConfig, ... }:
let
  quickshellDev = userConfig.quickshellDev or false;
  devConfigPath = "${config.home.homeDirectory}/src/quickshell-ii";
in
lib.mkIf quickshellDev {
  xdg.configFile."quickshell/ii".source =
    config.lib.file.mkOutOfStoreSymlink devConfigPath;

  home.activation.seedQuickshellDevConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${devConfigPath}" ]; then
        mkdir -p "${config.home.homeDirectory}/src"
        ${pkgs.rsync}/bin/rsync -a --chmod=u+w \
          "${inputs.end4-dots}/dots/.config/quickshell/ii/" \
          "${devConfigPath}/"
      fi
      ${pkgs.rsync}/bin/rsync -a --chmod=u+w \
        "${../../../overlays/ii}/" \
        "${devConfigPath}/"
    '';
}
