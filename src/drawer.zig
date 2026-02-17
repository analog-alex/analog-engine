const std = @import("std");
const c = @import("c.zig").c;
const v = @import("vectors").vec2;

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,

    // Predefined color constants
    pub const Red = Color{ .r = 255, .g = 0, .b = 0 };
    pub const Green = Color{ .r = 0, .g = 255, .b = 0 };
    pub const Blue = Color{ .r = 0, .g = 0, .b = 255 };
    pub const White = Color{ .r = 255, .g = 255, .b = 255 };
    pub const Black = Color{ .r = 0, .g = 0, .b = 0 };
    pub const Yellow = Color{ .r = 255, .g = 255, .b = 0 };
    pub const Cyan = Color{ .r = 0, .g = 255, .b = 255 };
    pub const Magenta = Color{ .r = 255, .g = 0, .b = 255 };

    // Transparent variants
    pub const TransparentRed = Color{ .r = 255, .g = 0, .b = 0, .a = 128 };
    pub const TransparentBlue = Color{ .r = 0, .g = 0, .b = 255, .a = 128 };
};

// Circle drawing functions
pub fn drawCircle(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    _ = c.filledCircleRGBA(renderer, v.X(position), v.Y(position), radius, color.r, color.g, color.b, color.a);
}

pub fn drawCircleOutline(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    _ = c.circleRGBA(renderer, v.X(position), v.Y(position), radius, color.r, color.g, color.b, color.a);
}

pub fn drawCircleAA(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    _ = c.aacircleRGBA(renderer, v.X(position), v.Y(position), radius, color.r, color.g, color.b, color.a);
}

// Rectangle drawing functions
pub fn drawRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, color: Color) void {
    _ = c.rectangleRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), color.r, color.g, color.b, color.a);
}

pub fn drawFilledRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, color: Color) void {
    _ = c.boxRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), color.r, color.g, color.b, color.a);
}

pub fn drawRoundedRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, radius: f32, color: Color) void {
    _ = c.roundedRectangleRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), radius, color.r, color.g, color.b, color.a);
}

pub fn drawFilledRoundedRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, radius: f32, color: Color) void {
    _ = c.roundedBoxRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), radius, color.r, color.g, color.b, color.a);
}

// Line drawing functions
pub fn drawLine(renderer: ?*c.SDL_Renderer, start: v.Vec2, end: v.Vec2, color: Color) void {
    _ = c.lineRGBA(renderer, v.X(start), v.Y(start), v.X(end), v.Y(end), color.r, color.g, color.b, color.a);
}

pub fn drawThickLine(renderer: ?*c.SDL_Renderer, start: v.Vec2, end: v.Vec2, width: f32, color: Color) void {
    _ = c.thickLineRGBA(renderer, v.X(start), v.Y(start), v.X(end), v.Y(end), width, color.r, color.g, color.b, color.a);
}

// Ellipse drawing functions
pub fn drawEllipse(renderer: ?*c.SDL_Renderer, center: v.Vec2, radii: v.Vec2, color: Color) void {
    _ = c.ellipseRGBA(renderer, v.X(center), v.Y(center), v.X(radii), v.Y(radii), color.r, color.g, color.b, color.a);
}

pub fn drawFilledEllipse(renderer: ?*c.SDL_Renderer, center: v.Vec2, radii: v.Vec2, color: Color) void {
    _ = c.filledEllipseRGBA(renderer, v.X(center), v.Y(center), v.X(radii), v.Y(radii), color.r, color.g, color.b, color.a);
}

// Triangle drawing functions
pub fn drawTriangle(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, p3: v.Vec2, color: Color) void {
    _ = c.trigonRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), v.X(p3), v.Y(p3), color.r, color.g, color.b, color.a);
}

pub fn drawFilledTriangle(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, p3: v.Vec2, color: Color) void {
    _ = c.filledTrigonRGBA(renderer, v.X(p1), v.Y(p1), v.X(p2), v.Y(p2), v.X(p3), v.Y(p3), color.r, color.g, color.b, color.a);
}

// Polygon drawing functions
pub fn drawPolygon(renderer: ?*c.SDL_Renderer, vx: []const i32, vy: []const i32, color: Color) void {
    if (vx.len != vy.len) return;
    _ = c.polygonRGBA(renderer, vx.ptr, vy.ptr, @intCast(vx.len), color.r, color.g, color.b, color.a);
}

pub fn drawFilledPolygon(renderer: ?*c.SDL_Renderer, vx: []const i32, vy: []const i32, color: Color) void {
    if (vx.len != vy.len) return;
    _ = c.filledPolygonRGBA(renderer, vx.ptr, vy.ptr, @intCast(vx.len), color.r, color.g, color.b, color.a);
}
