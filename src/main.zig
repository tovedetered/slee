const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");
const input = @import("./input.zig");

pub fn main() !void {
    const original = try terminal.enableRawMode();
    defer terminal.disableRawMode(original);

    while (true) {
        const op = try input.editorProcessKeyPress();
        switch (op) {
            .Quit => break,
            else => {},
        }
    }
}