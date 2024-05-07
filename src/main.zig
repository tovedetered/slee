const std = @import("std");
const io = @import("std").io;

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    var buf: [1]u8 = undefined;

    while (true) {
        const n = try stdin.read(buf[0..]);
        if (n != 1) break;
        if(buf[0] == 'q') break;
    }
}
