default:
    @just --list

setup:
    meson setup build

[working-directory: 'build']
build:
    ninja
