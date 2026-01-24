const std = @import("std");
const c_imports = @import("c.zig");
const c = c_imports.c;

const game_manager = @import("game.zig");
const drawer = @import("drawer.zig");
const event_handler = @import("events/sdl_event_handler.zig");

pub fn main() !void {
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

    // run loop
    var game = game_manager.Game.new();

    while (game.running) {
        // Handle all pending events
        event_handler.handleEvents(&game);

        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        _ = c.SDL_RenderClear(renderer);

        // Draw a blue filled circle at the center of the window
        drawer.drawCircle(renderer, 400, 300, 100, drawer.Color.Blue);

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
