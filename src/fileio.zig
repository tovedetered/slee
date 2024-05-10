const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");

pub fn editorOpen() !void {
    const line = "Hello World!";
    data.editor.row.chars = try std.heap.page_allocator.alloc(u8, line.len);
    @memcpy(data.editor.row.chars, line);
    data.editor.numRows = 1;
}
