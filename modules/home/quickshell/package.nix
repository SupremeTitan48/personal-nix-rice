{ pkgs, quickshell }:
let
  qs = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
pkgs.stdenv.mkDerivation {
  pname = "illogical-impulse-quickshell-wrapper";
  version = "pinned";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qs
    gsettings-desktop-schemas
    kdePackages.kdialog
    kdePackages.kirigami
    kdePackages.qtlocation
    kdePackages.qtpositioning
    kdePackages.qtwayland
    kdePackages.syntax-highlighting
    qt6.qt5compat
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtquicktimeline
    qt6.qtsensors
    qt6.qtsvg
    qt6.qttools
    qt6.qttranslations
    qt6.qtvirtualkeyboard
    qt6.qtwayland
    vulkan-headers
    libdrm
    cpptrace
    jemalloc
    mesa
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    makeWrapper ${qs}/bin/qs "$out/bin/qs" \
      --prefix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Quickshell wrapper with Qt dependencies for end-4 illogical-impulse";
    license = licenses.gpl3Only;
    mainProgram = "qs";
    platforms = platforms.linux;
  };
}
