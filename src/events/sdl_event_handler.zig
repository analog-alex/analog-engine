const std = @import("std");
const c_imports = @import("../c.zig");
const c = c_imports.c;
const Game = @import("../game.zig").Game;

var polled_event: c.SDL_Event = undefined;

/// Processes all pending SDL events and updates the game state accordingly
pub fn handleEvents(game: *Game) void {
    while (c.SDL_PollEvent(&polled_event)) {
        switch (polled_event.type) {
            c.SDL_EVENT_QUIT => handleQuit(game),
            c.SDL_EVENT_KEY_DOWN => handleKeyDown(game, &polled_event),
            c.SDL_EVENT_KEY_UP => handleKeyUp(game, &polled_event),
            else => {},
        }
    }
}

fn handleQuit(game: *Game) void {
    game.running = false;
}

fn handleKeyDown(game: *Game, event: *const c.SDL_Event) void {
    switch (event.key.key) {
        c.SDLK_ESCAPE => game.running = false,
        c.SDLK_W => updateVerticalVelocity(game),
        c.SDLK_S => updateVerticalVelocity(game),
        c.SDLK_A => updateHorizontalVelocity(game),
        c.SDLK_D => updateHorizontalVelocity(game),
        else => {},
    }
}

fn handleKeyUp(game: *Game, event: *const c.SDL_Event) void {
    switch (event.key.key) {
        c.SDLK_W, c.SDLK_S => updateVerticalVelocity(game),
        c.SDLK_A, c.SDLK_D => updateHorizontalVelocity(game),
        else => {},
    }
}

fn updateVerticalVelocity(game: *Game) void {
    const keyboard_state = c.SDL_GetKeyboardState(null);
    const w_pressed = keyboard_state[c.SDL_SCANCODE_W];
    const s_pressed = keyboard_state[c.SDL_SCANCODE_S];

    if (w_pressed and !s_pressed) {
        game.player.updateSpeedY(-game.player.speed);
    } else if (s_pressed and !w_pressed) {
        game.player.updateSpeedY(game.player.speed);
    } else {
        game.player.updateSpeedY(0);
    }
}

fn updateHorizontalVelocity(game: *Game) void {
    const keyboard_state = c.SDL_GetKeyboardState(null);
    const a_pressed = keyboard_state[c.SDL_SCANCODE_A];
    const d_pressed = keyboard_state[c.SDL_SCANCODE_D];

    if (a_pressed and !d_pressed) {
        game.player.updateSpeedX(-game.player.speed);
    } else if (d_pressed and !a_pressed) {
        game.player.updateSpeedX(game.player.speed);
    } else {
        game.player.updateSpeedX(0);
    }
}
