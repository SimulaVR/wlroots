default:
    @just --list

# Run `meson setup build`
setup:
    meson setup build

# Run `ninja` in `/build`
[working-directory: 'build']
build:
    ninja
