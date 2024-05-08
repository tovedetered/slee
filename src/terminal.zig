const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;

const termError = error{
    read,
};

pub fn enableRawMode() !posix.termios{
    const fd = io.getStdIn().handle;
    const original = try posix.tcgetattr(fd);
    var raw = original;

    raw.iflag.IXON = false;
    raw.iflag.ICRNL = false;
    raw.iflag.BRKINT = false;
    raw.iflag.INPCK = false;
    raw.iflag.ISTRIP = false;

    raw.oflag.OPOST = false;

    raw.cflag.CSIZE = .CS8;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.lflag.ISIG = false;
    raw.lflag.IEXTEN = false;

    raw.cc[@intFromEnum(posix.V.MIN)] = 1;
    raw.cc[@intFromEnum(posix.V.TIME)] = 0;

    try posix.tcsetattr(fd, .FLUSH, raw);
    return original;
}

pub fn disableRawMode(terminal: posix.termios) void{
    const fd = io.getStdIn().handle;
    posix.tcsetattr(fd, .FLUSH, terminal) catch |err|{
        std.log.err("{any}", .{err});
        std.posix.exit(1);
    };
}

pub fn editorReadKey() !u8 {
    const stdinread = io.getStdIn().reader();
    var buf:[1] u8 = undefined;
    buf[0] = 0;
    const n = try stdinread.read(buf[0..]);
    if (n == -1) {return termError.read;}
    return buf[0];
}