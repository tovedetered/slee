const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");
const input = @import("./input.zig");
const out = @import("./output.zig");
const data = @import("./data.zig");

pub fn main() !void {
    try terminal.enableRawMode();
    defer terminal.disableRawMode();

    try initEditor();

    while (true) {
        try out.editorRefreshScreen();
        const op = try input.editorProcessKeyPress();
        switch (op) {
        .Quit => {
            try out.editorRefreshScreen();
            break;
        },
        else => {},
        }
    }
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, n:?usize) noreturn {
    io.getStdOut().writeAll("\x1B[2J") catch {};
    io.getStdOut().writeAll("\x1B[H") catch {};
    std.builtin.default_panic(msg, error_return_trace, n);
}

fn initEditor() !void{
    try terminal.getWindowSize(&data.editor.screenRows, &data.editor.screenHeight);
}