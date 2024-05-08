const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

pub fn editorRefreshScreen() !void {
    _ = try io.getStdIn().writer().write("\x1b[2J");
    _ = try io.getStdIn().writer().write("\x1b[H");

    try editorDrawRows();

    _ = try io.getStdIn().writer().write("\x1b[H");
}

pub fn editorDrawRows() !void {
    for(0..24) |y| {
        _ = y;
        try io.getStdIn().writeAll("~\r\n");
    }
}