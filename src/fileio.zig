const std = @import("std");
const io = @import("std").io;
const data = @import("./data.zig");

pub fn editorOpen(filename: []const u8) !void {
    const cwd = std.fs.cwd();
    var file: std.fs.File = try cwd.openFile(filename, .{ .mode = .read_write });
    defer file.close();

    var line: ?[]u8 = null;
    line = try file.reader().readUntilDelimiterOrEofAlloc(std.heap.page_allocator,
        '\n', 1024);
    if(line != null){
        //Trim the \ns and \rs
        while(line.?.len > 0 and (line.?[line.?.len - 1] == '\n' or line.?[line.?.len - 1] == '\r')){
            line.? = line.?[0..line.?.len - 1];
        }
        data.editor.row.chars = try std.heap.page_allocator.alloc(u8, line.?.len);
        @memcpy(data.editor.row.chars, line.?);
        data.editor.numRows = 1;
    }
    std.heap.page_allocator.free(line.?);
}
