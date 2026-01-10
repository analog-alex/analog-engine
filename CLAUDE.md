# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple SDL3 application written in Zig. It creates a window with a basic renderer that displays a diagonal line.

## Build System

This project uses Zig's native build system (Zig 0.15.1+).

### Common Commands

- **Build the project**: `zig build`
- **Run the application**: `zig build run`
- **Clean build cache**: `rm -rf zig-out .zig-cache`

The compiled executable is output to `zig-out/bin/sdl`.

## Dependencies

### SDL3 Integration

This project uses SDL3 via the `allyourcodebase/SDL3` Zig wrapper package, which provides Zig build system integration for SDL3.

**Important**: The dependency is fetched from the main branch tarball:
```
.url = "https://github.com/allyourcodebase/SDL3/archive/refs/heads/main.tar.gz"
```

To update the SDL3 dependency:
```bash
zig fetch --save https://github.com/allyourcodebase/SDL3/archive/refs/heads/main.tar.gz
```

### SDL3 C API Usage

SDL3 is accessed through C imports using `@cImport` and `@cInclude`. The C bindings are imported as:
```zig
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
```

## Zig Version Compatibility

### Zig 0.15.1+ Build System Changes

This project requires Zig 0.15.1 or later. Key differences from earlier versions:

1. **Executable creation**: Fields like `root_source_file`, `target`, and `optimize` must be wrapped in `.root_module = b.createModule(.{...})` instead of being passed directly to `addExecutable`.

2. **Correct pattern**:
   ```zig
   const exe = b.addExecutable(.{
       .name = "sdl",
       .root_module = b.createModule(.{
           .root_source_file = b.path("src/main.zig"),
           .target = target,
           .optimize = optimize,
       }),
   });
   ```

## SDL3 API Notes

### Function Renames

SDL3 has renamed several functions from SDL2. Notable changes used in this project:

- `SDL_RenderDrawLine` → `SDL_RenderLine`

Always check SDL3 documentation when adding new SDL functionality, as many functions have been renamed or changed their signatures.

## Code Structure

### Entry Point: `src/main.zig`

Simple single-file application with:
1. SDL initialization (`SDL_Init`)
2. Window creation (800x600, resizable)
3. Renderer creation
4. Event loop handling quit events and ESC key
5. Basic rendering (clear screen, draw line)
6. 16ms delay per frame (~60 FPS target)
