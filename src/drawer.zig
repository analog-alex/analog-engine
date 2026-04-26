const std = @import("std");
const c = @import("c");
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

fn setColor(renderer: ?*c.SDL_Renderer, color: Color) void {
    _ = c.SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
}

fn drawLineRaw(renderer: ?*c.SDL_Renderer, x1: f32, y1: f32, x2: f32, y2: f32, color: Color) void {
    setColor(renderer, color);
    _ = c.SDL_RenderLine(renderer, x1, y1, x2, y2);
}

fn drawPoint(renderer: ?*c.SDL_Renderer, x: f32, y: f32, color: Color) void {
    setColor(renderer, color);
    _ = c.SDL_RenderPoint(renderer, x, y);
}

pub fn drawRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, color: Color) void {
    var rect = c.SDL_FRect{
        .x = @min(v.X(p1), v.X(p2)),
        .y = @min(v.Y(p1), v.Y(p2)),
        .w = @abs(v.X(p2) - v.X(p1)),
        .h = @abs(v.Y(p2) - v.Y(p1)),
    };
    setColor(renderer, color);
    _ = c.SDL_RenderRect(renderer, &rect);
}

pub fn drawFilledRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, color: Color) void {
    var rect = c.SDL_FRect{
        .x = @min(v.X(p1), v.X(p2)),
        .y = @min(v.Y(p1), v.Y(p2)),
        .w = @abs(v.X(p2) - v.X(p1)),
        .h = @abs(v.Y(p2) - v.Y(p1)),
    };
    setColor(renderer, color);
    _ = c.SDL_RenderFillRect(renderer, &rect);
}

pub fn drawRoundedRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, radius: f32, color: Color) void {
    const x = @min(v.X(p1), v.X(p2));
    const y = @min(v.Y(p1), v.Y(p2));
    const w = @abs(v.X(p2) - v.X(p1));
    const h = @abs(v.Y(p2) - v.Y(p1));
    const r = @max(0.0, @min(radius, @min(w, h) * 0.5));
    if (r <= 0.5) {
        drawRect(renderer, p1, p2, color);
        return;
    }

    drawLineRaw(renderer, x + r, y, x + w - r, y, color);
    drawLineRaw(renderer, x + r, y + h, x + w - r, y + h, color);
    drawLineRaw(renderer, x, y + r, x, y + h - r, color);
    drawLineRaw(renderer, x + w, y + r, x + w, y + h - r, color);

    const steps: usize = @as(usize, @intCast(@max(8, @as(i32, @intFromFloat(@ceil(r * 0.9))))));
    var prev_tl = v.init(x + r, y);
    var prev_tr = v.init(x + w - r, y);
    var prev_bl = v.init(x, y + h - r);
    var prev_br = v.init(x + w, y + h - r);
    for (1..(steps + 1)) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(steps));
        const a = t * (std.math.pi * 0.5);

        const tl = v.init(x + r - @cos(a) * r, y + r - @sin(a) * r);
        const tr = v.init(x + w - r + @sin(a) * r, y + r - @cos(a) * r);
        const bl = v.init(x + r - @sin(a) * r, y + h - r + @cos(a) * r);
        const br = v.init(x + w - r + @cos(a) * r, y + h - r + @sin(a) * r);

        drawLine(renderer, prev_tl, tl, color);
        drawLine(renderer, prev_tr, tr, color);
        drawLine(renderer, prev_bl, bl, color);
        drawLine(renderer, prev_br, br, color);

        prev_tl = tl;
        prev_tr = tr;
        prev_bl = bl;
        prev_br = br;
    }
}

pub fn drawFilledRoundedRect(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, radius: f32, color: Color) void {
    const x = @min(v.X(p1), v.X(p2));
    const y = @min(v.Y(p1), v.Y(p2));
    const w = @abs(v.X(p2) - v.X(p1));
    const h = @abs(v.Y(p2) - v.Y(p1));
    const r = @max(0.0, @min(radius, @min(w, h) * 0.5));
    if (r <= 0.5) {
        drawFilledRect(renderer, p1, p2, color);
        return;
    }

    const y_start: i32 = @intFromFloat(@floor(y));
    const y_end: i32 = @intFromFloat(@ceil(y + h));
    var iy = y_start;
    while (iy <= y_end) : (iy += 1) {
        const py = @as(f32, @floatFromInt(iy));
        var inset: f32 = 0;
        if (py < y + r) {
            const dy = y + r - py;
            inset = r - @sqrt(@max(0.0, r * r - dy * dy));
        } else if (py > y + h - r) {
            const dy = py - (y + h - r);
            inset = r - @sqrt(@max(0.0, r * r - dy * dy));
        }
        drawLineRaw(renderer, x + inset, py, x + w - inset, py, color);
    }
}

pub fn drawLine(renderer: ?*c.SDL_Renderer, start: v.Vec2, end: v.Vec2, color: Color) void {
    drawLineRaw(renderer, v.X(start), v.Y(start), v.X(end), v.Y(end), color);
}

pub fn drawThickLine(renderer: ?*c.SDL_Renderer, start: v.Vec2, end: v.Vec2, width: f32, color: Color) void {
    if (width <= 1.0) {
        drawLine(renderer, start, end, color);
        return;
    }

    const d = v.sub(end, start);
    const len = v.length(d);
    if (len <= 0.0001) {
        drawPoint(renderer, v.X(start), v.Y(start), color);
        return;
    }

    const nx = -d[1] / len;
    const ny = d[0] / len;
    const half = @as(i32, @intFromFloat(@ceil(width * 0.5)));
    var i = -half;
    while (i <= half) : (i += 1) {
        const off = @as(f32, @floatFromInt(i));
        drawLineRaw(renderer, v.X(start) + nx * off, v.Y(start) + ny * off, v.X(end) + nx * off, v.Y(end) + ny * off, color);
    }
}

pub fn drawEllipse(renderer: ?*c.SDL_Renderer, center: v.Vec2, radii: v.Vec2, color: Color) void {
    const rx = @max(0.0, v.X(radii));
    const ry = @max(0.0, v.Y(radii));
    if (rx <= 0.5 or ry <= 0.5) {
        drawPoint(renderer, v.X(center), v.Y(center), color);
        return;
    }

    const steps: usize = @as(usize, @intCast(@max(16, @as(i32, @intFromFloat(@ceil((rx + ry) * 0.5))))));
    var prev = v.init(v.X(center) + rx, v.Y(center));
    for (1..(steps + 1)) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(steps));
        const a = t * (2.0 * std.math.pi);
        const p = v.init(v.X(center) + @cos(a) * rx, v.Y(center) + @sin(a) * ry);
        drawLine(renderer, prev, p, color);
        prev = p;
    }
}

pub fn drawFilledEllipse(renderer: ?*c.SDL_Renderer, center: v.Vec2, radii: v.Vec2, color: Color) void {
    const rx = @max(0.0, v.X(radii));
    const ry = @max(0.0, v.Y(radii));
    if (rx <= 0.5 or ry <= 0.5) {
        drawPoint(renderer, v.X(center), v.Y(center), color);
        return;
    }

    const y0: i32 = @intFromFloat(@floor(v.Y(center) - ry));
    const y1: i32 = @intFromFloat(@ceil(v.Y(center) + ry));
    var iy = y0;
    while (iy <= y1) : (iy += 1) {
        const py = @as(f32, @floatFromInt(iy));
        const dy = (py - v.Y(center)) / ry;
        const span = rx * @sqrt(@max(0.0, 1.0 - dy * dy));
        drawLineRaw(renderer, v.X(center) - span, py, v.X(center) + span, py, color);
    }
}

pub fn drawTriangle(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, p3: v.Vec2, color: Color) void {
    drawLine(renderer, p1, p2, color);
    drawLine(renderer, p2, p3, color);
    drawLine(renderer, p3, p1, color);
}

pub fn drawFilledTriangle(renderer: ?*c.SDL_Renderer, p1: v.Vec2, p2: v.Vec2, p3: v.Vec2, color: Color) void {
    const pts = [_]v.Vec2{ p1, p2, p3 };
    fillPolygonVec2(renderer, &pts, color);
}

pub fn drawPolygon(renderer: ?*c.SDL_Renderer, vx: []const i32, vy: []const i32, color: Color) void {
    if (vx.len != vy.len or vx.len < 2) return;
    var i: usize = 0;
    while (i < vx.len) : (i += 1) {
        const j = (i + 1) % vx.len;
        drawLineRaw(
            renderer,
            @floatFromInt(vx[i]),
            @floatFromInt(vy[i]),
            @floatFromInt(vx[j]),
            @floatFromInt(vy[j]),
            color,
        );
    }
}

pub fn drawFilledPolygon(renderer: ?*c.SDL_Renderer, vx: []const i32, vy: []const i32, color: Color) void {
    if (vx.len != vy.len or vx.len < 3) return;

    var min_x = vx[0];
    var max_x = vx[0];
    var min_y = vy[0];
    var max_y = vy[0];
    for (1..vx.len) |i| {
        min_x = @min(min_x, vx[i]);
        max_x = @max(max_x, vx[i]);
        min_y = @min(min_y, vy[i]);
        max_y = @max(max_y, vy[i]);
    }

    var y = min_y;
    while (y <= max_y) : (y += 1) {
        var x = min_x;
        while (x <= max_x) : (x += 1) {
            if (pointInPolygonInts(@as(f32, @floatFromInt(x)) + 0.5, @as(f32, @floatFromInt(y)) + 0.5, vx, vy)) {
                drawPoint(renderer, @floatFromInt(x), @floatFromInt(y), color);
            }
        }
    }
}

pub fn drawCircle(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    const r = @max(0.0, radius);
    if (r <= 0.5) {
        drawPoint(renderer, v.X(position), v.Y(position), color);
        return;
    }

    const y0: i32 = @intFromFloat(@floor(v.Y(position) - r));
    const y1: i32 = @intFromFloat(@ceil(v.Y(position) + r));
    var iy = y0;
    while (iy <= y1) : (iy += 1) {
        const py = @as(f32, @floatFromInt(iy));
        const dy = py - v.Y(position);
        const span = @sqrt(@max(0.0, r * r - dy * dy));
        drawLineRaw(renderer, v.X(position) - span, py, v.X(position) + span, py, color);
    }
}

pub fn drawCircleOutline(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    const r = @max(0.0, radius);
    if (r <= 0.5) {
        drawPoint(renderer, v.X(position), v.Y(position), color);
        return;
    }

    const steps: usize = @as(usize, @intCast(@max(16, @as(i32, @intFromFloat(@ceil(r * 1.2))))));
    var prev = v.init(v.X(position) + r, v.Y(position));
    for (1..(steps + 1)) |i| {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(steps));
        const a = t * (2.0 * std.math.pi);
        const p = v.init(v.X(position) + @cos(a) * r, v.Y(position) + @sin(a) * r);
        drawLine(renderer, prev, p, color);
        prev = p;
    }
}

pub fn drawCircleAA(renderer: ?*c.SDL_Renderer, position: v.Vec2, radius: f32, color: Color) void {
    drawCircleOutline(renderer, position, radius, color);
}

fn fillPolygonVec2(renderer: ?*c.SDL_Renderer, points: []const v.Vec2, color: Color) void {
    if (points.len < 3) return;

    var min_x = points[0][0];
    var max_x = points[0][0];
    var min_y = points[0][1];
    var max_y = points[0][1];
    for (1..points.len) |i| {
        min_x = @min(min_x, points[i][0]);
        max_x = @max(max_x, points[i][0]);
        min_y = @min(min_y, points[i][1]);
        max_y = @max(max_y, points[i][1]);
    }

    const x0: i32 = @intFromFloat(@floor(min_x));
    const x1: i32 = @intFromFloat(@ceil(max_x));
    const y0: i32 = @intFromFloat(@floor(min_y));
    const y1: i32 = @intFromFloat(@ceil(max_y));

    var y = y0;
    while (y <= y1) : (y += 1) {
        var x = x0;
        while (x <= x1) : (x += 1) {
            if (pointInPolygonVec2(@as(f32, @floatFromInt(x)) + 0.5, @as(f32, @floatFromInt(y)) + 0.5, points)) {
                drawPoint(renderer, @floatFromInt(x), @floatFromInt(y), color);
            }
        }
    }
}

fn pointInPolygonVec2(px: f32, py: f32, points: []const v.Vec2) bool {
    var inside = false;
    var j = points.len - 1;
    for (points, 0..) |p, i| {
        const pj = points[j];
        const intersects = ((p[1] > py) != (pj[1] > py)) and
            (px < (pj[0] - p[0]) * (py - p[1]) / ((pj[1] - p[1]) + 0.000001) + p[0]);
        if (intersects) inside = !inside;
        j = i;
    }
    return inside;
}

fn pointInPolygonInts(px: f32, py: f32, vx: []const i32, vy: []const i32) bool {
    var inside = false;
    var j = vx.len - 1;
    for (vx, 0..) |x_i, i| {
        const y_i = vy[i];
        const x_j = vx[j];
        const y_j = vy[j];
        const yi_f = @as(f32, @floatFromInt(y_i));
        const yj_f = @as(f32, @floatFromInt(y_j));
        const intersects = ((yi_f > py) != (yj_f > py)) and
            (px < (@as(f32, @floatFromInt(x_j - x_i)) * (py - yi_f)) / ((yj_f - yi_f) + 0.000001) + @as(f32, @floatFromInt(x_i)));
        if (intersects) inside = !inside;
        j = i;
    }
    return inside;
}
