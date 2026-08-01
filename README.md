# analog-engine

Small Zig + SDL3 game engine prototype.

## Requirements

- [Zig](https://ziglang.org/) 0.16+

Dependencies (fetched automatically via `build.zig.zon`):

- [SDL3](https://github.com/analog-alex/SDL3)
- [analog-vectors](https://github.com/analog-alex/analog-vectors)

## Build & run

```sh
zig build
zig build run
```

## Layout

| Path | Role |
|------|------|
| `src/main.zig` | SDL init, window/renderer, main loop |
| `src/game.zig` | Game coordinator (input → update → draw) |
| `src/events/` | SDL event handling |
| `src/entities/` | Game entities (e.g. player) |
| `src/drawer.zig` | Shared drawing helpers |
