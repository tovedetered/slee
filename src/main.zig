const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const c = @import("std").c;

pub fn main() !void {
    try enableRawMode();
    const stdin = io.getStdIn().reader();
    var buf: [1]u8 = undefined;

    while (true) {
        const n = try stdin.read(buf[0..]);
        if (n != 1) break;
        if(buf[0] == 'q') break;
    }
}

fn enableRawMode() !void{
    const fd = io.getStdIn().handle;
    var raw = try posix.tcgetattr(fd);
    raw.lflag.ECHO = false;

    try posix.tcsetattr(fd, .FLUSH, raw);
}