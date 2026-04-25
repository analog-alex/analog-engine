const v = @import("vectors").vec2;

const c = @import("c");

const drawer = @import("../drawer.zig");

pub const Player = struct {
    position: v.Vec2,
    velocity: v.Vec2,
    speed: f32,
    radius: f32,

    pub fn init(start_position: v.Vec2) Player {
        return Player{
            .position = start_position,
            .velocity = v.zero(),
            .speed = 200.0,
            .radius = 20.0,
        };
    }

    pub fn update(self: *Player, dt: f32, window_width: f32, window_height: f32) void {
        // Normalize diagonal movement and apply speed
        const normalized = v.normalize(self.velocity);
        const movement = v.mul(normalized, self.speed * dt);
        self.position = v.sum(self.position, movement);

        // Clamp to screen boundaries
        const min_bounds = v.from(self.radius, self.radius);
        const max_bounds = v.from(window_width - self.radius, window_height - self.radius);
        self.position = v.clamp(self.position, min_bounds, max_bounds);
    }

    pub fn setVelocity(self: *Player, velocity: v.Vec2) void {
        self.velocity = velocity;
    }

    pub fn draw(self: *Player, renderer: ?*c.SDL_Renderer) void {
        drawer.drawCircle(renderer, self.position, self.radius, drawer.Color.Blue);
    }
};
