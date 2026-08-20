const std = @import("std");

pub const Entity = struct {
    index: u32,
    generation: u32,

    pub fn eql(a: Entity, b: Entity) bool {
        return a.index == b.index and a.generation == b.generation;
    }
};

test "Entity.eql matches on index and generation" {
    const a = Entity{ .index = 1, .generation = 2 };
    const b = Entity{ .index = 1, .generation = 2 };
    try std.testing.expect(Entity.eql(a, b));
}

test "Entity.eql differs on index" {
    const a = Entity{ .index = 1, .generation = 2 };
    const b = Entity{ .index = 3, .generation = 2 };
    try std.testing.expect(!Entity.eql(a, b));
}

test "Entity.eql differs on generation" {
    const a = Entity{ .index = 1, .generation = 2 };
    const b = Entity{ .index = 1, .generation = 5 };
    try std.testing.expect(!Entity.eql(a, b));
}
