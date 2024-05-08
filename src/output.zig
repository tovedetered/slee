const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

pub fn editorRefreshScreen() !void {
     _ = try io.getStdIn().writer().write("\x1b[2J");
     _ = try io.getStdIn().writer().write("\x1b[H");
}