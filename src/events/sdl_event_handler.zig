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
        else => {},
    }
}

fn handleKeyUp(_: *Game, _: *const c.SDL_Event) void {
    // Placeholder for future key up handling
}
