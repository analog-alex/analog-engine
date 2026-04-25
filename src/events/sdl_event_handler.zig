const c = @import("c");
const v = @import("vectors").vec2;
const Game = @import("../game.zig").Game;

/// Processes all pending SDL events and updates the game state accordingly
pub fn handleEvents(game: *Game) void {
    var polled_event: c.SDL_Event = undefined;
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
        c.SDLK_W, c.SDLK_S, c.SDLK_A, c.SDLK_D => updatePlayerVelocity(game),
        else => {},
    }
}

fn handleKeyUp(game: *Game, event: *const c.SDL_Event) void {
    switch (event.key.key) {
        c.SDLK_W, c.SDLK_S, c.SDLK_A, c.SDLK_D => updatePlayerVelocity(game),
        else => {},
    }
}

fn updatePlayerVelocity(game: *Game) void {
    const keyboard_state = c.SDL_GetKeyboardState(null);
    const w_pressed = keyboard_state[c.SDL_SCANCODE_W];
    const s_pressed = keyboard_state[c.SDL_SCANCODE_S];
    const a_pressed = keyboard_state[c.SDL_SCANCODE_A];
    const d_pressed = keyboard_state[c.SDL_SCANCODE_D];

    // Calculate velocity direction based on pressed keys
    var velocity = v.zero();

    if (a_pressed and !d_pressed) velocity[0] = -1;
    if (d_pressed and !a_pressed) velocity[0] = 1;
    if (w_pressed and !s_pressed) velocity[1] = -1;
    if (s_pressed and !w_pressed) velocity[1] = 1;

    game.player.setVelocity(velocity);
}
