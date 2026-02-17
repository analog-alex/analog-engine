const std = @import("std");
const c = @import("c.zig").c;
const g = @import("game.zig");

pub fn main() !void {
    std.debug.print("Starting up...", .{});

    // init SDL video
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    // create window
    const window = c.SDL_CreateWindow(
        "Zig + SDL3",
        800,
        600,
        c.SDL_WINDOW_RESIZABLE,
    );
    if (window == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{c.SDL_GetError()});
        return error.WindowCreationFailed;
    }
    defer c.SDL_DestroyWindow(window);

    // create renderer
    const renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.debug.print("SDL_CreateRenderer Error: {s}\n", .{c.SDL_GetError()});
        return error.RendererCreationFailed;
    }
    defer c.SDL_DestroyRenderer(renderer);

    std.debug.print("Window created! Boot up game loop.", .{});

    var ticks: u64 = c.SDL_GetTicks();
    var game = g.Game.new();

    while (game.running) {
        // Calc tick diff
        const now = c.SDL_GetTicks();
        const dt: f32 = @as(f32, @floatFromInt(now - ticks)) / 1000.0;
        ticks = now;

        std.debug.print("Frame time: {d:.3}ms ({d:.1}fps)\n", .{ dt * 1000.0, 1.0 / dt });

        // Clean up buffer upfront
        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        _ = c.SDL_RenderClear(renderer);

        // === Game Logic Goes Here ===
        // Handle all pending events
        game.handleInput();

        // Update entities in the game
        game.update(dt);

        // Draw to screenbuffer
        game.draw(renderer);
        // ===========================

        // Update Screen
        _ = c.SDL_RenderPresent(renderer);

        // 120 fps
        c.SDL_Delay(6);
    }
}
