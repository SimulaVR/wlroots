build:
    @if [ -d "./build" ]; then \
        ninja -C build; \
    else \
        meson build; ninja -C build; \
    fi

clean:
    rm -rf build
