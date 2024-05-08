const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");
const input = @import("./input.zig");
const out = @import("./output.zig");

pub fn main() !void {
    const original = try terminal.enableRawMode();
    defer terminal.disableRawMode(original);

    while (true) {
        try out.editorRefreshScreen();
        const op = try input.editorProcessKeyPress();
        switch (op) {
        .Quit => {
            out.editorRefreshScreen();
        },
        else => {},
        }
    }
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace) noreturn {
    io.getStdOut().writeAll("\x1b[2J") catch {};
    io.getStdOut().writeAll("\x1b[H") catch {};
    std.builtin.default_panic(msg, error_return_trace);
}
