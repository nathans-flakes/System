{ config
, lib
, pkgs
, stdenv
, fetchurl
, meson
, ninja
, pkg-config
, git
, cmake
, makeDesktopItem
, wayland
, wayland-protocols
, json_c
, libxkbcommon
, fontconfig
, giflib
, libjpeg
, libjxl
, libpng
, librsvg
, libwebp
, libheif
, libtiff
, libexif
, bash-completion
, ...
}:

stdenv.mkDerivation rec {
  pname = "swayimg";
  version = "1.9";

  src = fetchurl {
    url = "https://github.com/artemsen/swayimg/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256-aTojp3VevtsUQnGytnSYChxRogNtq8/5aXw+PGJY8Qg=";
    name = "${pname}-${version}.tar.gz";
  };

  nativeBuildInputs = [ meson ninja pkg-config git cmake ];
  buildInputs = [
    wayland
    wayland-protocols
    json_c
    libxkbcommon
    fontconfig
    giflib
    libjpeg
    libjxl
    libpng
    librsvg
    libwebp
    libheif
    libtiff
    libexif
    bash-completion
  ];

  desktopItem = makeDesktopItem {
    name = "swayimg-open";
    desktopName = "swayimg";
    exec = "swayimg %u";
    terminal = false;
    mimeTypes = [
      "image/jpeg"
      "image/png"
      "image/gif"
      "image/svg+xml"
      "image/webp"
      "image/avif"
      "image/tiff"
      "image/bmp"
    ];
  };
}
