const std = @import("std");
const c_imports = @import("c.zig");
const c = c_imports.c;

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
pub fn drawCircle(renderer: ?*c.SDL_Renderer, x: f32, y: f32, radius: f32, color: Color) void {
    _ = c.filledCircleRGBA(renderer, x, y, radius, color.r, color.g, color.b, color.a);
}

pub fn drawCircleOutline(renderer: ?*c.SDL_Renderer, x: f32, y: f32, radius: f32, color: Color) void {
    _ = c.circleRGBA(renderer, x, y, radius, color.r, color.g, color.b, color.a);
}

pub fn drawCircleAA(renderer: ?*c.SDL_Renderer, x: f32, y: f32, radius: f32, color: Color) void {
    _ = c.aacircleRGBA(renderer, x, y, radius, color.r, color.g, color.b, color.a);
}

// Rectangle drawing functions
pub fn drawRect(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, color: Color) void {
    _ = c.rectangleRGBA(renderer, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
}

pub fn drawFilledRect(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, color: Color) void {
    _ = c.boxRGBA(renderer, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
}

pub fn drawRoundedRect(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32, color: Color) void {
    _ = c.roundedRectangleRGBA(renderer, x1, y1, x2, y2, radius, color.r, color.g, color.b, color.a);
}

pub fn drawFilledRoundedRect(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32, color: Color) void {
    _ = c.roundedBoxRGBA(renderer, x1, y1, x2, y2, radius, color.r, color.g, color.b, color.a);
}

// Line drawing functions
pub fn drawLine(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, color: Color) void {
    _ = c.lineRGBA(renderer, x1, y1, x2, y2, color.r, color.g, color.b, color.a);
}

pub fn drawThickLine(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, width: f32, color: Color) void {
    _ = c.thickLineRGBA(renderer, x1, y1, x2, y2, width, color.r, color.g, color.b, color.a);
}

// Ellipse drawing functions
pub fn drawEllipse(renderer: ?*c.SDL_Renderer, x: f32, y: f32, rx: f32, ry: f32, color: Color) void {
    _ = c.ellipseRGBA(renderer, x, y, rx, ry, color.r, color.g, color.b, color.a);
}

pub fn drawFilledEllipse(renderer: ?*c.SDL_Renderer, x: f32, y: f32, rx: f32, ry: f32, color: Color) void {
    _ = c.filledEllipseRGBA(renderer, x, y, rx, ry, color.r, color.g, color.b, color.a);
}

// Triangle drawing functions
pub fn drawTriangle(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, x3: f32, y3: f32, color: Color) void {
    _ = c.trigonRGBA(renderer, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
}

pub fn drawFilledTriangle(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, x3: f32, y3: f32, color: Color) void {
    _ = c.filledTrigonRGBA(renderer, x1, y1, x2, y2, x3, y3, color.r, color.g, color.b, color.a);
}

// Polygon drawing functions
pub fn drawPolygon(renderer: ?*c.SDL_Renderer, vx: []const i16, vy: []const i16, color: Color) void {
    if (vx.len != vy.len) return;
    _ = c.polygonRGBA(renderer, vx.ptr, vy.ptr, @intCast(vx.len), color.r, color.g, color.b, color.a);
}

pub fn drawFilledPolygon(renderer: ?*c.SDL_Renderer, vx: []const i16, vy: []const i16, color: Color) void {
    if (vx.len != vy.len) return;
    _ = c.filledPolygonRGBA(renderer, vx.ptr, vy.ptr, @intCast(vx.len), color.r, color.g, color.b, color.a);
}
