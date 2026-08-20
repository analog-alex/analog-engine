const std = @import("std");

pub const Entity = @import("entity.zig").Entity;
pub const SparseSet = @import("sparse_set.zig").SparseSet;
pub const World = @import("world.zig").World;
pub const Query = @import("query.zig").Query;

test {
    std.testing.refAllDecls(@This());
}
