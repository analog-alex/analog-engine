const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

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

    const renderer = c.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.debug.print("SDL_CreateRenderer Error: {s}\n", .{c.SDL_GetError()});
        return error.RendererCreationFailed;
    }
    defer c.SDL_DestroyRenderer(renderer);

    var running = true;
    var event: c.SDL_Event = undefined;

    while (running) {
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => running = false,
                c.SDL_EVENT_KEY_DOWN => {
                    if (event.key.key == c.SDLK_ESCAPE) {
                        running = false;
                    }
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        _ = c.SDL_RenderClear(renderer);
        // Draw a triangle: set draw color to white and draw three edges
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        const x1 = 400;
        const y1 = 100;
        const x2 = 200;
        const y2 = 500;
        const x3 = 600;
        const y3 = 500;
        _ = c.SDL_RenderLine(renderer, x1, y1, x2, y2);
        _ = c.SDL_RenderLine(renderer, x2, y2, x3, y3);
        _ = c.SDL_RenderLine(renderer, x3, y3, x1, y1);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(16);
    }
}
