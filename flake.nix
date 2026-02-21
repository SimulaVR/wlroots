{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, lib, ... }:
        let
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
              pkgs.xcbutilwm
              pkgs.libcap
              pkgs.xcbutilimage
              pkgs.xcbutilerrors
              pkgs.libpng
              pkgs.ffmpeg_4
              pkgs.libX11.dev
              pkgs.libxcb.dev
              pkgs.xinput
              pkgs.libdrm
              pkgs.libgbm
              pkgs.mesa-gl-headers
              pkgs.libxcb-errors
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

          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;
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
              pkgs.xcbutilwm
              pkgs.libcap
              pkgs.xcbutilimage
              pkgs.xcbutilerrors
              pkgs.libpng
              pkgs.ffmpeg_4
              pkgs.libX11.dev
              pkgs.libxcb.dev
              pkgs.xinput
              # pkgs.mesa # <- exclude when bumping to newer nixpkgs
              pkgs.libdrm # <- include when bumping to newer nixpkgs
              pkgs.libgbm # <- include when bumping to newer nixpkgs
              pkgs.mesa-gl-headers # <- include when bumping to newer nixpkgs
              pkgs.libxcb-errors
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
