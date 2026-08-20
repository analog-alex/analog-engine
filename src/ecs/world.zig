const std = @import("std");
const entity_mod = @import("entity.zig");
const sparse_set_mod = @import("sparse_set.zig");
const query_mod = @import("query.zig");

pub const Entity = entity_mod.Entity;
const SparseSet = sparse_set_mod.SparseSet;

pub fn World(comptime ComponentTypes: []const type) type {
    const StoresTuple = blk: {
        var types: [ComponentTypes.len]type = undefined;
        for (ComponentTypes, 0..) |T, i| types[i] = SparseSet(T);
        break :blk std.meta.Tuple(&types);
    };

    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        generations: std.ArrayList(u32) = .empty,
        free_indices: std.ArrayList(u32) = .empty,
        stores: StoresTuple,

        fn componentIndex(comptime T: type) usize {
            inline for (ComponentTypes, 0..) |CT, i| {
                if (CT == T) return i;
            }
            @compileError("Component type " ++ @typeName(T) ++ " not registered in World");
        }

        pub fn init(allocator: std.mem.Allocator) Self {
            var stores: StoresTuple = undefined;
            inline for (ComponentTypes, 0..) |T, i| {
                stores[i] = SparseSet(T).init(allocator);
            }
            return .{ .allocator = allocator, .stores = stores };
        }

        pub fn deinit(self: *Self) void {
            self.generations.deinit(self.allocator);
            self.free_indices.deinit(self.allocator);
            inline for (0..ComponentTypes.len) |i| {
                self.stores[i].deinit();
            }
        }

        pub fn spawn(self: *Self) !Entity {
            if (self.free_indices.pop()) |idx| {
                return .{ .index = idx, .generation = self.generations.items[idx] };
            }
            const idx: u32 = @intCast(self.generations.items.len);
            try self.generations.append(self.allocator, 0);
            return .{ .index = idx, .generation = 0 };
        }

        pub fn despawn(self: *Self, entity: Entity) !void {
            if (!self.isAlive(entity)) return error.EntityNotAlive;
            self.generations.items[entity.index] +%= 1;
            try self.free_indices.append(self.allocator, entity.index);
            inline for (ComponentTypes) |T| {
                self.storePtr(T).remove(entity.index);
            }
        }

        pub fn isAlive(self: *const Self, entity: Entity) bool {
            return entity.index < self.generations.items.len and
                self.generations.items[entity.index] == entity.generation;
        }

        pub fn storePtr(self: *Self, comptime T: type) *SparseSet(T) {
            return &self.stores[comptime componentIndex(T)];
        }

        pub fn insert(self: *Self, entity: Entity, component: anytype) !void {
            if (!self.isAlive(entity)) return error.EntityNotAlive;
            const T = @TypeOf(component);
            try self.storePtr(T).insert(entity.index, component);
        }

        pub fn remove(self: *Self, entity: Entity, comptime T: type) void {
            if (!self.isAlive(entity)) return;
            self.storePtr(T).remove(entity.index);
        }

        pub fn get(self: *Self, entity: Entity, comptime T: type) ?*T {
            if (!self.isAlive(entity)) return null;
            return self.storePtr(T).get(entity.index);
        }

        pub fn has(self: *const Self, entity: Entity, comptime T: type) bool {
            if (!self.isAlive(entity)) return false;
            return self.stores[comptime componentIndex(T)].contains(entity.index);
        }

        pub fn query(self: *Self, comptime Types: []const type) query_mod.Query(Self, Types) {
            return .{ .world = self };
        }
    };
}

const testing = std.testing;

test "World.spawn yields sequential indices with generation 0" {
    var world = World(&.{}).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    const b = try world.spawn();

    try testing.expectEqual(@as(u32, 0), a.index);
    try testing.expectEqual(@as(u32, 0), a.generation);
    try testing.expectEqual(@as(u32, 1), b.index);
    try testing.expectEqual(@as(u32, 0), b.generation);
}

test "World.despawn then respawn recycles index with bumped generation" {
    var world = World(&.{}).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    try world.despawn(a);

    const b = try world.spawn();
    try testing.expectEqual(a.index, b.index);
    try testing.expectEqual(@as(u32, 1), b.generation);
    try testing.expect(!world.isAlive(a));
    try testing.expect(world.isAlive(b));
}

test "World.despawn on an already-dead entity errors" {
    var world = World(&.{}).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    try world.despawn(a);
    try testing.expectError(error.EntityNotAlive, world.despawn(a));
}

const Position = struct { x: f32, y: f32 };
const Velocity = struct { dx: f32, dy: f32 };

test "World insert/get/has/remove roundtrip for one component type" {
    var world = World(&.{Position}).init(testing.allocator);
    defer world.deinit();

    const e = try world.spawn();
    try testing.expect(!world.has(e, Position));

    try world.insert(e, Position{ .x = 1, .y = 2 });
    try testing.expect(world.has(e, Position));
    try testing.expectEqual(@as(f32, 1), world.get(e, Position).?.x);

    world.remove(e, Position);
    try testing.expect(!world.has(e, Position));
    try testing.expect(world.get(e, Position) == null);
}

test "World.despawn clears entity from every registered store" {
    var world = World(&.{ Position, Velocity }).init(testing.allocator);
    defer world.deinit();

    const e = try world.spawn();
    try world.insert(e, Position{ .x = 1, .y = 2 });
    try world.insert(e, Velocity{ .dx = 3, .dy = 4 });

    try world.despawn(e);

    try testing.expect(world.get(e, Position) == null);
    try testing.expect(world.get(e, Velocity) == null);
}

test "World stale-handle access after index reuse (ABA) is rejected" {
    var world = World(&.{Position}).init(testing.allocator);
    defer world.deinit();

    const a = try world.spawn();
    try world.despawn(a);

    const b = try world.spawn();
    try testing.expectEqual(a.index, b.index);
    try world.insert(b, Position{ .x = 9, .y = 9 });

    try testing.expect(world.get(a, Position) == null);
    try testing.expect(!world.has(a, Position));
    try testing.expectEqual(@as(f32, 9), world.get(b, Position).?.x);
}
