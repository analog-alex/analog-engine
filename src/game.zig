const c = @import("c");
const v = @import("vectors").vec2;

const event_handler = @import("events/sdl_event_handler.zig");
const Player = @import("entities/player_entity.zig").Player;

pub const Game = struct {
    running: bool,
    player: Player,

    pub fn new(window_width: f32, window_height: f32) Game {
        return Game{ .running = true, .player = Player.init(v.init(window_width / 2.0, window_height / 2.0)) };
    }

    pub fn handleInput(self: *Game) void {
        event_handler.handleEvents(self);
    }

    pub fn update(self: *Game, dt: f32, window_width: f32, window_height: f32) void {
        self.player.update(dt, window_width, window_height);
    }

    pub fn draw(self: *Game, renderer: ?*c.SDL_Renderer) void {
        self.player.draw(renderer);
    }
};
