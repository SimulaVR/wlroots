{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    libxcb-errors = {
      url = "github:SimulaVR/libxcb-errors";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { pkgs, lib, ... }:
        let
          libxcb-errors = pkgs.stdenv.mkDerivation {
            name = "libxcb-errors";
            src = inputs.libxcb-errors;

            nativeBuildInputs = [
              pkgs.pkg-config
              pkgs.python3
              pkgs.autoreconfHook
            ];

            buildInputs = [
              pkgs.xorg.libxcb
              pkgs.xorg.libXau
              pkgs.xorg.libXdmcp
              pkgs.xorg.utilmacros
              pkgs.xorg.xcbproto
              pkgs.libbsd
            ];

            meta = {
              description = "Allow XCB errors to print less opaquely";
              homepage = "https://github.com/SimulaVR/libxcb-errors";
              license = lib.licenses.mit;
              platforms = lib.platforms.linux;
            };
          };
          wlroots = pkgs.stdenv.mkDerivation {
            pname = "wlroots";
            version = "0.10.0";

            src = builtins.filterSource (path: type: baseNameOf path != "build") ./.;

            # $out for the library and $examples for the example programs (in examples):
            outputs = [
              "out"
              "examples"
            ];

            nativeBuildInputs = [
              pkgs.meson
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              pkgs.wayland-scanner
            ];

            buildInputs = [
              pkgs.wayland
              pkgs.libGL
              pkgs.wayland-protocols
              pkgs.libinput
              pkgs.libxkbcommon
              pkgs.pixman
              pkgs.xorg.xcbutilwm
              pkgs.libcap
              pkgs.xorg.xcbutilimage
              pkgs.xorg.xcbutilerrors
              pkgs.libpng
              pkgs.ffmpeg_4
              pkgs.xorg.libX11.dev
              pkgs.xorg.libxcb.dev
              pkgs.xorg.xinput
              pkgs.libdrm
              pkgs.libgbm
              pkgs.mesa-gl-headers

              libxcb-errors
            ];

            mesonFlags = [
              "-Dlibcap=enabled"
              "-Dlogind=enabled"
              "-Dxwayland=enabled"
              "-Dx11-backend=enabled"
              "-Dxcb-icccm=disabled"
              "-Dxcb-errors=enabled"
            ];

            LDFLAGS = [
              "-lX11-xcb"
              "-lxcb-xinput"
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

            meta = {
              description = "More or less a pinned version of wlroots that Simula can use (with a few patches)";
              homepage = "https://github.com/SimulaVR/wlroots";
              license = lib.licenses.mit;
              platforms = lib.platforms.linux;
            };
          };
        in
        {
          packages = {
            inherit wlroots;
            default = wlroots;
          };

          devShells.default = pkgs.mkShell rec {
            nativeBuildInputs = [
              pkgs.nil
              pkgs.just

              pkgs.meson
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              pkgs.wayland-scanner
            ];

            buildInputs = [
              pkgs.wayland
              pkgs.libGL
              pkgs.wayland-protocols
              pkgs.libinput
              pkgs.libxkbcommon
              pkgs.pixman
              pkgs.xorg.xcbutilwm
              pkgs.libcap
              pkgs.xorg.xcbutilimage
              pkgs.xorg.xcbutilerrors
              pkgs.libpng
              pkgs.ffmpeg_4
              pkgs.xorg.libX11.dev
              pkgs.xorg.libxcb.dev
              pkgs.xorg.xinput
              pkgs.libdrm
              pkgs.libgbm
              pkgs.mesa-gl-headers

              libxcb-errors
            ];

            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

            LDFLAGS = [
              "-lX11-xcb"
              "-lxcb-xinput"
            ];
          };
        };
    };
}
