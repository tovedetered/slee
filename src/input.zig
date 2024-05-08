const std = @import("std");
const io = @import("std").io;
const posix = @import("std").posix;
const os = @import("std").os;
const term = @import("./terminal.zig");
const util = @import("./utilities.zig");

const KeyAction = enum {
    Quit,
    NoOp,
};

pub fn editorProcessKeyPress() !KeyAction{
    const c = try term.editorReadKey();
    return switch (c) {
        util.ctrlKey('q') => .Quit,
        else => .NoOp
    };
}