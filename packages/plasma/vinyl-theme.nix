# vinyl-theme.nix
# https://github.com/ekaaty/vinyl-theme
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  unstableGitUpdater,
}:
stdenv.mkDerivation rec {
  pname = "vinyl-theme";
  version = "v6.5.3";

  src = fetchFromGitHub {
    owner = "ekaaty";
    repo = pname;
    rev = "e0d75982e59e4c43b6b8297cc4eb263ecc60b117";
    hash = "";
  };

  buildInputs = with kdePackages; [
    kcmutils
    kconfig
    kdecoration
    kirigami
    kguiaddons
    kcolorscheme
    kcoreaddons
    ki18n
    kiconthemes
    kwindowsystem
    frameworkintegration
  ];

  nativeBuildInputs = [
    cmake
    kdePackages.qttools
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Theme for KDE Plasma";
    mainProgram = "vinyl-settings6";
    homepage = "https://github.com/ekaaty/vinyl-theme";
    license = with licenses; [
      gpl2Plus
      gpl3Plus
    ];
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
