const std = @import("std");

const stringError = error{};

pub const string = struct {
    b: []u8,
    len: usize,
    alloc: std.mem.Allocator,
    pub fn append(self: *string, s: []const u8) !void {
        var new: []u8 = try self.alloc.realloc(self.b, self.len + s.len);
        std.mem.copyForwards(u8, new[self.len .. self.len + s.len], s[0..s.len]);
        self.b = new;
        self.len += s.len;
    }
    pub fn vappend(self: *string, s: []u8) !void {
        var new: []u8 = try self.alloc.realloc(self.b, self.len + s.len);
        std.mem.copyForwards(u8, new[self.len .. self.len + s.len], s[0..s.len]);
        self.b = new;
        self.len += s.len;
    }
    pub fn print(self: *string, comptime fmt: []const u8, args: anytype, alloc: std.mem.Allocator) !void {
        const to_add = try std.fmt.allocPrint(alloc, fmt, args);

        var new: []u8 = try self.alloc.realloc(self.b, self.len + to_add.len);
        std.mem.copyForwards(u8, new[self.len .. self.len + to_add.len], to_add[0..to_add.len]);
        self.b = new;
        self.len += to_add.len;
    }
    pub fn free(self: *string) void {
        self.alloc.free(self.b);
    }
};

pub fn init(alloc: std.mem.Allocator) string {
    return string{
        .b = &.{},
        .len = 0,
        .alloc = alloc,
    };
}
