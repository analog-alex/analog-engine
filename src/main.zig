const std = @import("std");
const c = @import("c.zig").c;
const g = @import("game.zig");

pub fn main() !void {
    const window_width: c_int = 800;
    const window_height: c_int = 600;

    // init SDL video
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        std.log.err("SDL_Init error: {s}", .{c.SDL_GetError()});
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    // create window
    const window = c.SDL_CreateWindow(
        "Zig + SDL3",
        window_width,
        window_height,
        c.SDL_WINDOW_RESIZABLE,
    );
    if (window == null) {
        std.log.err("SDL_CreateWindow error: {s}", .{c.SDL_GetError()});
        return error.WindowCreationFailed;
    }
    defer c.SDL_DestroyWindow(window);

    // create renderer
    const renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.log.err("SDL_CreateRenderer error: {s}", .{c.SDL_GetError()});
        return error.RendererCreationFailed;
    }
    defer c.SDL_DestroyRenderer(renderer);

    var ticks: u64 = c.SDL_GetTicks();
    var game = g.Game.new(@floatFromInt(window_width), @floatFromInt(window_height));

    while (game.running) {
        // Calc tick diff
        const now = c.SDL_GetTicks();
        const dt: f32 = @as(f32, @floatFromInt(now - ticks)) / 1000.0;
        ticks = now;

        // Clean up buffer upfront
        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        _ = c.SDL_RenderClear(renderer);

        // === Game Logic Goes Here ===
        // Handle all pending events
        game.handleInput();

        // Update entities in the game
        var current_width: c_int = 0;
        var current_height: c_int = 0;
        _ = c.SDL_GetWindowSize(window, &current_width, &current_height);
        game.update(dt, @floatFromInt(current_width), @floatFromInt(current_height));

        // Draw to screenbuffer
        game.draw(renderer);
        // ===========================

        // Update Screen
        _ = c.SDL_RenderPresent(renderer);

        // 120 fps
        c.SDL_Delay(6);
    }
}
