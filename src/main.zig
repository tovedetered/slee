const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");
const input = @import("./input.zig");
const out = @import("./output.zig");
const data = @import("./data.zig");
const cont = @import("./fileio.zig");

pub fn main() !void {
    try terminal.enableRawMode();
    defer terminal.disableRawMode();

    try initEditor();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if(args.len > 1){
        try cont.editorOpen(args[1]);
    }

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

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, n: ?usize) noreturn {
    io.getStdOut().writeAll("\n*****   PANIC   *****\n") catch {};
    io.getStdOut().writeAll("\x1B[2J") catch {};
    io.getStdOut().writeAll("\x1B[H") catch {};
    std.builtin.default_panic(msg, error_return_trace, n);
}

fn initEditor() !void {
    data.input.cx = 0;
    data.input.cy = 0;
    data.editor.numRows = 0;
    try terminal.getWindowSize(&data.editor.screenRows, &data.editor.screenCols);
}
