// Shared C imports for SDL3 and SDL3_gfx
pub const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3_gfxPrimitives.h");
});
