const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const terminal = @import("./terminal.zig");
const util = @import("./utilities.zig");

pub fn main() !void {
    const original = try terminal.enableRawMode();
    defer _= terminal.disableRawMode(original);

    const stdinread = io.getStdIn().reader();
    const stdinwrite = io.getStdIn().writer();
    var buf: [1]u8 = undefined;

    while (true) {
        buf[0] = std.ascii.control_code.nul;
        const n = try stdinread.read(buf[0..]);
        const c = buf[0];
        if (n != 1) break;
        if(c == util.ctrlKey('q')) break;


        if(std.ascii.isControl(c)){
            try stdinwrite.print("{d}\r\n", .{c});
        }
        else{
            try stdinwrite.print("{d} ('{c}')\r\n", .{c, c});
        }
    }
}