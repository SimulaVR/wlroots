#ifndef TYPES_WLR_SEAT_H
#define TYPES_WLR_SEAT_H

#include <wayland-server.h>
#include <wlr/types/wlr_seat.h>

extern const struct wlr_pointer_grab_interface default_pointer_grab_impl;
extern const struct wlr_keyboard_grab_interface default_keyboard_grab_impl;
extern const struct wlr_touch_grab_interface default_touch_grab_impl;

void seat_client_create_pointer(struct wlr_seat_client *seat_client,
	uint32_t version, uint32_t id);
void seat_client_destroy_pointer(struct wl_resource *resource);

void seat_client_create_keyboard(struct wlr_seat_client *seat_client,
	uint32_t version, uint32_t id);
void seat_client_destroy_keyboard(struct wl_resource *resource);

void seat_client_create_touch(struct wlr_seat_client *seat_client,
	uint32_t version, uint32_t id);
void seat_client_destroy_touch(struct wl_resource *resource);

#endif
