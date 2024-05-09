const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const data = @import("./data.zig");
const c = @import("std").c;
const util = @import("./utilities.zig");

const termError = error{
read,
window_size,
cursor_pos,
};

pub fn enableRawMode() !void {
    const fd = io.getStdIn().handle;
    data.editor.orig_terminos = try posix.tcgetattr(fd);
    var raw = data.editor.orig_terminos;

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
}

pub fn disableRawMode() void{
    const fd = io.getStdIn().handle;
    posix.tcsetattr(fd, .FLUSH, data.editor.orig_terminos) catch |err|{
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

pub fn getWindowSize(rows: *u16, cols: *u16) !void{
    var ws = posix.winsize{
        .ws_col = undefined,
        .ws_row = undefined,
        .ws_xpixel = undefined,
        .ws_ypixel = undefined,
    };
    _ = rows;
    _ = cols;
    //NOTE: This is from zig ~0.13 this may change as it has for me
    //This only works on linux (I think) so you may have to find a more cross platform
    //solution if it is nessessary, but I use arch btw
    switch(posix.errno(os.linux.ioctl(os.linux.STDOUT_FILENO, os.linux.T.IOCGWINSZ,
        @intFromPtr(&ws)))){
    //os.linux.E.SUCCESS => {
    //    rows.* = ws.ws_row;
    //    cols.* = ws.ws_col;
    //},

    posix.E.BADF => return error.BadFileDescriptor,
    posix.E.INVAL => return error.InvalidRequest,
    posix.E.NOTTY => return error.NotATerminal,
    else => {
        try io.getStdOut().writeAll("\x1b[999C\x1b[999B");
        try getCursorPosition(rows, cols);
        return error.window_size;
    }
    }
}

fn getCursorPosition(rows: *u16, cols: *u16) !void {
    var buf:[32] u8 = undefined;
    var i: usize = 0;

    try io.getStdOut().writeAll("\x1b[6n");

    var ch: u8 = undefined;
    while(i < buf.len - 1) : (i += 1){
        ch = io.getStdIn().reader().readByte() catch |err| switch (err) {
        error.EndOfStream => break,
        else => return err,
        };
        buf[i] = ch;
        if(buf[i] == 'R') {break;}
    }
    i += 1;
    buf[i] = 0;
    if(buf[0] != '\x1b' or buf[1] != '[') return error.cursor_pos;

    var splits = std.mem.split(u8, buf[2..], ';');
    var line = splits.next();
    rows = try std.fmt.parseInt(u16, line, 10);
    line = splits.next();
    cols = try std.fmt.parseInt(u16, line, 10);
}