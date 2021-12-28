{ stdenv, lib, fetchFromGitHub, meson, ninja, pkgconfig, fetchpatch
, wayland, libGL, wayland-protocols, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, mesa
, libpng, ffmpeg_4, autoreconfHook, xorg, libbsd, pkg-config, python310
}:

let
  libxcb-errors = import ./libxcb-errors/libxcb-errors.nix { stdenv = stdenv; lib = lib; pkg-config=pkg-config; autoreconfHook = autoreconfHook; xorg = xorg; libbsd = libbsd; python310 = python310; };
  in

stdenv.mkDerivation rec {
  name = "wlroots";
  pname = "wlroots";
  version = "0.10.0";

  src = builtins.filterSource (path: type: baseNameOf path != "build") ./.;

  # $out for the library and $examples for the example programs (in examples):
  outputs = [ "out" "examples" ];

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [
    wayland libGL wayland-protocols libinput libxkbcommon pixman
    xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa
    libpng ffmpeg_4 libxcb-errors
  ];

  mesonFlags = [
    "-Dlibcap=enabled" "-Dlogind=enabled" "-Dxwayland=enabled" "-Dx11-backend=enabled"
    "-Dxcb-icccm=disabled" "-Dxcb-errors=enabled"
  ];

  postInstall = ''
    # Copy the library to $examples
    mkdir -p $examples/lib
    cp -Pr libwlroots* $examples/lib/
  '';

  postFixup = ''
    # Install ALL example programs to $examples:
    # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
    # screenshot output-layout multi-pointer rotation tablet touch pointer
    # simple
    mkdir -p $examples/bin
    cd ./examples
    for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
      cp "$binary" "$examples/bin/wlroots-$binary"
    done
  '';

  meta = with lib; {
    description = "A modular Wayland compositor library";
    inherit (src.meta) homepage;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
