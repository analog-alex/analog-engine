const std = @import("std");
const c_imports = @import("c.zig");
const c = c_imports.c;

const event_handler = @import("events/sdl_event_handler.zig");
const p = @import("entities/player_entity.zig");

pub const Game = struct {
    running: bool,
    player: p.Player,

    pub fn new() Game {
        return Game{ .running = true, .player = p.Player.init() };
    }

    pub fn handleInput(self: *Game) void {
        event_handler.handleEvents(self);
    }

    pub fn update(self: *Game, dt: f32) void {
        self.player.update(dt);
    }

    pub fn draw(self: *Game, renderer: ?*c.struct_SDL_Renderer) void {
        self.player.draw(renderer);
    }
};
