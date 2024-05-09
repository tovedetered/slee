const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const data = @import("./data.zig");
const abuf = @import("./data-struct/abuf.zig");

pub fn editorRefreshScreen() !void {
    var buf = abuf.init(std.heap.page_allocator);
    defer buf.free();

    try buf.append("\x1b[?25l");
    try buf.append("\x1b[H");

    try editorDrawRows(&buf);

    try buf.append("\x1b[H");
    try buf.append("\x1b[?25h");

    try io.getStdOut().writeAll(buf.b);
}

pub fn editorDrawRows(ab: *abuf.abuf) !void {
    for(0..data.editor.screenRows) |y| {
        try ab.*.append("~");
        try ab.*.append("\x1b[K");
        if(y < data.editor.screenRows - 1){
            try ab.*.append("\r\n");
        }
    }
}