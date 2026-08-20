const std = @import("std");

/// Dense array + sparse index map for a single component type, keyed by raw
/// entity index (not generation). World is responsible for validating
/// generations before touching a store.
pub fn SparseSet(comptime T: type) type {
    return struct {
        const Self = @This();
        const no_entry: u32 = std.math.maxInt(u32);

        allocator: std.mem.Allocator,
        sparse: std.ArrayList(u32) = .empty,
        dense_index: std.ArrayList(u32) = .empty,
        dense: std.ArrayList(T) = .empty,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{ .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            self.sparse.deinit(self.allocator);
            self.dense_index.deinit(self.allocator);
            self.dense.deinit(self.allocator);
        }

        pub fn contains(self: *const Self, index: u32) bool {
            return index < self.sparse.items.len and self.sparse.items[index] != no_entry;
        }

        pub fn insert(self: *Self, index: u32, value: T) !void {
            if (self.contains(index)) {
                self.dense.items[self.sparse.items[index]] = value;
                return;
            }

            if (index >= self.sparse.items.len) {
                const old_len = self.sparse.items.len;
                try self.sparse.resize(self.allocator, index + 1);
                for (self.sparse.items[old_len..]) |*slot| slot.* = no_entry;
            }

            const slot: u32 = @intCast(self.dense.items.len);
            try self.dense.append(self.allocator, value);
            try self.dense_index.append(self.allocator, index);
            self.sparse.items[index] = slot;
        }

        pub fn remove(self: *Self, index: u32) void {
            if (!self.contains(index)) return;

            const slot = self.sparse.items[index];
            _ = self.dense.swapRemove(slot);
            _ = self.dense_index.swapRemove(slot);

            if (slot < self.dense_index.items.len) {
                self.sparse.items[self.dense_index.items[slot]] = slot;
            }
            self.sparse.items[index] = no_entry;
        }

        pub fn get(self: *Self, index: u32) ?*T {
            if (!self.contains(index)) return null;
            return &self.dense.items[self.sparse.items[index]];
        }

        pub fn count(self: *const Self) usize {
            return self.dense.items.len;
        }
    };
}

const testing = std.testing;

test "SparseSet insert/get/contains roundtrip" {
    var set = SparseSet(f32).init(testing.allocator);
    defer set.deinit();

    try testing.expect(!set.contains(3));
    try set.insert(3, 42.0);
    try testing.expect(set.contains(3));
    try testing.expectEqual(@as(f32, 42.0), set.get(3).?.*);
    try testing.expectEqual(@as(usize, 1), set.count());
}

test "SparseSet insert overwrites existing value" {
    var set = SparseSet(u32).init(testing.allocator);
    defer set.deinit();

    try set.insert(5, 1);
    try set.insert(5, 2);
    try testing.expectEqual(@as(u32, 2), set.get(5).?.*);
    try testing.expectEqual(@as(usize, 1), set.count());
}

test "SparseSet remove of absent index is a no-op" {
    var set = SparseSet(u32).init(testing.allocator);
    defer set.deinit();

    set.remove(10);
    try testing.expectEqual(@as(usize, 0), set.count());

    try set.insert(1, 99);
    set.remove(10);
    try testing.expectEqual(@as(usize, 1), set.count());
}

test "SparseSet swap-remove of middle element preserves survivors" {
    var set = SparseSet(u32).init(testing.allocator);
    defer set.deinit();

    try set.insert(1, 100);
    try set.insert(2, 200);
    try set.insert(3, 300);

    set.remove(2);

    try testing.expect(!set.contains(2));
    try testing.expectEqual(@as(usize, 2), set.count());
    try testing.expectEqual(@as(u32, 100), set.get(1).?.*);
    try testing.expectEqual(@as(u32, 300), set.get(3).?.*);
}

test "SparseSet survives insert/remove churn across many indices" {
    var set = SparseSet(u32).init(testing.allocator);
    defer set.deinit();

    var i: u32 = 0;
    while (i < 50) : (i += 1) {
        try set.insert(i, i * 10);
    }

    // remove every third index
    i = 0;
    while (i < 50) : (i += 3) {
        set.remove(i);
    }

    i = 0;
    while (i < 50) : (i += 1) {
        if (i % 3 == 0) {
            try testing.expect(!set.contains(i));
        } else {
            try testing.expectEqual(i * 10, set.get(i).?.*);
        }
    }
}
