const std = @import("std");
const c = @import("c.zig").c;

const event_handler = @import("events/sdl_event_handler.zig");
const Player = @import("entities/player_entity.zig").Player;

pub const Game = struct {
    running: bool,
    player: Player,

    pub fn new() Game {
        return Game{ .running = true, .player = Player.init() };
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
