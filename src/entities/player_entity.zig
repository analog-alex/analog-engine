const std = @import("std");
const c_imports = @import("../c.zig");
const c = c_imports.c;

const drawer = @import("../drawer.zig");

pub const Player = struct {
    position: [2]f32,
    velocity: [2]f32,
    speed: f32,
    radius: f32,

    pub fn init() Player {
        return Player{
            .position = [2]f32{ 400, 300 }, // Center of 800x600 window
            .velocity = [2]f32{ 0, 0 },
            .speed = 200.0,
            .radius = 20.0,
        };
    }

    pub fn update(self: *Player, dt: f32) void {
        // Normalize diagonal movement
        var vel_x = self.velocity[0];
        var vel_y = self.velocity[1];

        if (vel_x != 0 and vel_y != 0) {
            const magnitude = @sqrt(vel_x * vel_x + vel_y * vel_y);
            vel_x = (vel_x / magnitude) * self.speed;
            vel_y = (vel_y / magnitude) * self.speed;
        }

        // Update position
        self.position[0] += vel_x * dt;
        self.position[1] += vel_y * dt;

        // Clamp to screen boundaries (800x600)
        const min_x = self.radius;
        const max_x = 800.0 - self.radius;
        const min_y = self.radius;
        const max_y = 600.0 - self.radius;

        if (self.position[0] < min_x) self.position[0] = min_x;
        if (self.position[0] > max_x) self.position[0] = max_x;
        if (self.position[1] < min_y) self.position[1] = min_y;
        if (self.position[1] > max_y) self.position[1] = max_y;
    }

    pub fn updateSpeedX(self: *Player, new_speed: f32) void {
        self.velocity[0] = new_speed;
    }

    pub fn updateSpeedY(self: *Player, new_speed: f32) void {
        self.velocity[1] = new_speed;
    }

    pub fn draw(self: *Player, renderer: ?*c.struct_SDL_Renderer) void {
        drawer.drawCircle(renderer, self.position[0], self.position[1], self.radius, drawer.Color.Blue);
    }
};
