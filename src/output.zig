const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const data = @import("./data.zig");

pub fn editorRefreshScreen() !void {
    try io.getStdOut().writeAll("\x1b[2J");
    try io.getStdOut().writeAll("\x1b[2J");

    try editorDrawRows();
    try io.getStdOut().writeAll("\x1b[H");
}

pub fn editorDrawRows() !void {
    for(0..data.editor.screenRows) |y| {
        _ = y;
        try io.getStdOut().writeAll("~\r\n");
    }
}