# AGENTS.md

## Fast Commands
- `zig build` compiles and installs the `sdl` executable (default `install` step).
- `zig build run` builds (if needed) and runs the app.
- `zig build run -- <args>` forwards CLI args to the app (`b.args` is wired in `build.zig`).
- `zig build -l` is minimal in this repo: `install`, `uninstall`, `run`.

## Real Entry Points
- `src/main.zig` is the runtime entry point (SDL init, window/renderer setup, main loop).
- `src/game.zig` is the game coordinator (input -> update -> draw orchestration).
- `src/events/sdl_event_handler.zig` handles SDL events and player velocity updates.
- `src/entities/player_entity.zig` contains player movement + bounds clamping.
- `src/drawer.zig` is the shared drawing utility module.

## Build + Dependency Wiring
- Dependencies are declared in `build.zig.zon`.
- Dependencies currently listed: `sdl`, `vectors`, `analog_ui`.
- Only `sdl` and `vectors` are imported into the executable module in `build.zig`; `analog_ui` is declared but not yet wired/imported.
- SDL C bindings are generated through `b.addTranslateC` from `src/sdl_headers.c`; add C includes there when expanding bindings.
- When bumping dependency tarballs, compute the new `.hash` with `zig fetch <tarball-url>` and update `build.zig.zon`.

## Verification + Repo Quirks
- There is no repo-level test step in `build.zig` and no `src/` tests; use `zig build` as the primary verification command.
- Generated directories are ignored: `zig-cache/`, `.zig-cache/`, `zig-out/`, `zig-pkg/`.
