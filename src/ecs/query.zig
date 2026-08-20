const std = @import("std");
const entity_mod = @import("entity.zig");

pub const Entity = entity_mod.Entity;

/// Iterates entities that have every component type in `Types`. Yields
/// `Entity` values; callers fetch components via `world.get()`.
pub fn Query(comptime WorldT: type, comptime Types: []const type) type {
    comptime std.debug.assert(Types.len > 0);
    const Driver = Types[0];

    return struct {
        const Self = @This();

        world: *WorldT,
        pos: usize = 0,

        pub fn next(self: *Self) ?Entity {
            const driver = self.world.storePtr(Driver);
            while (self.pos < driver.dense_index.items.len) {
                const idx = driver.dense_index.items[self.pos];
                self.pos += 1;
                const e = Entity{ .index = idx, .generation = self.world.generations.items[idx] };
                if (self.hasAll(e)) return e;
            }
            return null;
        }

        fn hasAll(self: *Self, e: Entity) bool {
            inline for (Types) |T| {
                if (!self.world.has(e, T)) return false;
            }
            return true;
        }
    };
}

const testing = std.testing;
const World = @import("world.zig").World;

const Position = struct { x: f32 = 0 };
const Velocity = struct { dx: f32 = 0 };
const Health = struct { hp: i32 = 0 };

test "Query matches entities with a single component" {
    var world = World(&.{ Position, Velocity }).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    try world.insert(a, Position{});
    const b = try world.spawn();
    _ = b; // no Position

    var q = world.query(&.{Position});
    const first = q.next().?;
    try testing.expect(Entity.eql(first, a));
    try testing.expect(q.next() == null);
}

test "Query 2-component intersection excludes entities missing either" {
    var world = World(&.{ Position, Velocity }).init(testing.allocator);
    defer world.deinit();

    const both = try world.spawn();
    try world.insert(both, Position{});
    try world.insert(both, Velocity{});

    const only_pos = try world.spawn();
    try world.insert(only_pos, Position{});

    const only_vel = try world.spawn();
    try world.insert(only_vel, Velocity{});

    var q = world.query(&.{ Position, Velocity });
    const first = q.next().?;
    try testing.expect(Entity.eql(first, both));
    try testing.expect(q.next() == null);
}

test "Query 3-component intersection excludes entities missing any one" {
    var world = World(&.{ Position, Velocity, Health }).init(testing.allocator);
    defer world.deinit();

    const all_three = try world.spawn();
    try world.insert(all_three, Position{});
    try world.insert(all_three, Velocity{});
    try world.insert(all_three, Health{});

    const missing_health = try world.spawn();
    try world.insert(missing_health, Position{});
    try world.insert(missing_health, Velocity{});

    var q = world.query(&.{ Position, Velocity, Health });
    const first = q.next().?;
    try testing.expect(Entity.eql(first, all_three));
    try testing.expect(q.next() == null);
}

test "Query returns empty result when nothing matches" {
    var world = World(&.{ Position, Velocity }).init(testing.allocator);
    defer world.deinit();

    _ = try world.spawn();

    var q = world.query(&.{ Position, Velocity });
    try testing.expect(q.next() == null);
}

test "Query iterates to completion exactly once over multiple matches" {
    var world = World(&.{Position}).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    try world.insert(a, Position{});
    const b = try world.spawn();
    try world.insert(b, Position{});
    const c = try world.spawn();
    try world.insert(c, Position{});

    var seen = std.ArrayList(Entity).empty;
    defer seen.deinit(testing.allocator);

    var q = world.query(&.{Position});
    while (q.next()) |e| {
        try seen.append(testing.allocator, e);
    }

    try testing.expectEqual(@as(usize, 3), seen.items.len);
    try testing.expect(Entity.eql(seen.items[0], a));
    try testing.expect(Entity.eql(seen.items[1], b));
    try testing.expect(Entity.eql(seen.items[2], c));
}
