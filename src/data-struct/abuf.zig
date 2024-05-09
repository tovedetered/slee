const std = @import("std");

const abufError = error{

};

pub const abuf = struct {
    b: []u8,
    len: usize,
    alloc: std.mem.Allocator,
    pub fn append(self: *abuf, s: []const u8) !void {
        var new: []u8 = try self.alloc.realloc(self.b, self.len + s.len);
        std.mem.copyForwards(u8, new[self.len..self.len + s.len], s[0..s.len]);
        self.b = new;
        self.len += s.len;
    }
    pub fn free(self: *abuf) void {
        self.alloc.free(self.b);
    }
};

pub fn init(alloc: std.mem.Allocator) abuf {
    return abuf{
        .b = &.{},
        .len = 0,
        .alloc = alloc,
    };
}
