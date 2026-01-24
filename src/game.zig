const std = @import("std");
const c_imports = @import("c.zig");
const c = c_imports.c;

pub const Game = struct {
    running: bool,

    pub fn new() Game {
        return Game{ .running = true };
    }
};
