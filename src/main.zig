const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const c = @import("std").c;

pub fn main() !void {
    const original = try enableRawMode();
    defer _= disableRawMode(original);

    const stdin = io.getStdIn().reader();
    var buf: [1]u8 = undefined;

    while (true) {
        const n = try stdin.read(buf[0..]);
        if (n != 1) break;
        if(buf[0] == 'q') break;
    }
}

fn enableRawMode() !posix.termios{
    const fd = io.getStdIn().handle;
    const original = try posix.tcgetattr(fd);
    var raw = original;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;

    try posix.tcsetattr(fd, .FLUSH, raw);
    return original;
}

fn disableRawMode(terminal: posix.termios) void{
    const fd = io.getStdIn().handle;
    posix.tcsetattr(fd, .FLUSH, terminal) catch |err|{
        std.log.err("{any}", .{err});
        std.posix.exit(1);
    };
}